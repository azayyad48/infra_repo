provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04
  instance_type = "t2.micro"

  tags = {
    Name = "TODO-App-Server"
  }
}

resource "null_resource" "ansible_provision" {
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory playbook.yml"
  }
}

