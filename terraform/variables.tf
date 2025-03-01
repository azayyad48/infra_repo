variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair in AWS"
  default     = "backend" # Replace with your actual key pair name
}
