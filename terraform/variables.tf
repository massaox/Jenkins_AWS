## AWS Credentials ##

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  description = "Region to be used for the setup"
  default     = "eu-west-2"
}

## SSH Credentials ##

variable "path_public_key" {
  description = "Path to the Jenkins master public key"
  default     = "jenkins-master.pub"
}

variable "path_private_key" {
  description = "Path to the Jenkins master private key"
  default     = "jenkins-master"
}

variable "path_public_worker_key" {
  description = "Path to the Jenkins worker public key"
  default     = "jenkins-worker.pub"
}

variable "path_private_worker_key" {
  description = "Path to the Jenkins worker private key"
  default     = "jenkins-worker"
}

## Credentials for Jenkins UI ##

variable "jenkins_password" {
  description = "Jenkins admin password"
}

## Type of instance, defaults to t2.micro for simplicity sake and testing

variable "instance_type" {
  description = "Type of EC2 instance"
  type = map(string)
  default = {
    master = "t2.micro"
    worker = "t2.micro"
  }
}

## Variable to mount and format jenkins-master persistent storage
variable "instance_block_device" {
  default = "/dev/xvdh"
}

## To help differentiate different environments if multiple as setup

variable "env" {
  default = "env"
}

## IP to whitelist for SSH access

variable "ssh_access" {
  description = "IP address to login to Master for troubleshooting"
}
