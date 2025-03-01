provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "app_sg" {
  name        = "todo-app-security-group"
  description = "Allow inbound traffic for TODO App"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance without Elastic IP
resource "aws_instance" "app_server" {
  ami                         = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 for us-east-1
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  security_groups             = [aws_security_group.app_sg.name]
  associate_public_ip_address = true # AWS assigns a public IP automatically

  tags = {
    Name = "TODO-App-Server"
  }
}

# Generate the Ansible inventory file dynamically using the instance's public IP
resource "local_file" "ansible_inventory" {
  content  = <<EOF
all:
  hosts:
    app_server:
      ansible_host: ${aws_instance.app_server.public_ip}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: /Users/user/.ssh/backend  # Replace with your actual SSH key path
      ansible_ssh_extra_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
EOF
  filename = "${path.module}/ansible/inventory.yml"
}

# Trigger Ansible playbook after provisioning
resource "null_resource" "ansible_provision" {
  depends_on = [local_file.ansible_inventory, aws_instance.app_server]

  provisioner "local-exec" {
    command     = "wsl sleep 30 && wsl ansible-playbook -i ansible/inventory.yml ansible/playbook.yml"
    working_dir = path.module
  }
}

# Output the public IP of the instance
output "public_ip" {
  value = aws_instance.app_server.public_ip
}
