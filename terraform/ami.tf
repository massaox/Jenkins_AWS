# AMI lookup for this Jenkins Server
data "aws_ami" "jenkins_ami" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["amazon-linux-for-jenkins*"]
  }
}
