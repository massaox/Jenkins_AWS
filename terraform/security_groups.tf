resource "aws_security_group" "allow-http" {
  vpc_id      = aws_vpc.jenkins-vpc.id
  name        = "allow-http"
  description = "security group to allow http traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-public"
  }
}

resource "aws_security_group" "allow-ssh" {
  vpc_id      = aws_vpc.jenkins-vpc.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access]
  }
  tags = {
    Name = "allow-ssh"
  }
}

## Security Groups below are to allow communication betwen master and workers and vice-versa

resource "aws_security_group" "jenkins-master-worker" {
  vpc_id      = aws_vpc.jenkins-vpc.id
  name        = "jenkins-master-worker"
  description = "Allow communication between master and workers"
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.5.0/24", "10.0.6.0/24"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.5.0/24","10.0.6.0/24"]
  }
  tags = {
    Name = "jenkins-master-worker"
  }
}

resource "aws_security_group" "jenkins-worker-master" {
  vpc_id      = aws_vpc.jenkins-vpc.id
  name        = "jenkins-worker-master"
  description = "Allow communication between master and workers"
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.7.0/24", "10.0.8.0/24"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.7.0/24", "10.0.8.0/24"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.7.0/24","10.0.8.0/24"]
  }

  tags = {
    Name = "jenkins-worker-master"
  }
}


