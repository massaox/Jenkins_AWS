resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.path_public_key)
}

## Main block config for Master setup

resource "aws_instance" "jenkins-master" {
  ami                    = data.aws_ami.jenkins_ami.image_id
  instance_type          = var.instance_type["master"]
  key_name               = aws_key_pair.mykey.key_name
  iam_instance_profile   = "jenkins_master"
  subnet_id              = aws_subnet.jenkins-public-1.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.jenkins-worker-master.id, aws_security_group.allow-http.id]
  user_data = data.template_cloudinit_config.cloudinit-jenkins-master.rendered
  tags = {
    Name = "Jenkins-Master"
    env  = var.env
  }
}

## Static Public IP Address for Master

resource "aws_eip" "jenkins-master-ip" {
  instance = aws_instance.jenkins-master.id
  vpc      = true
}

# Creating Block Storage to persist data on the Master

resource "aws_ebs_volume" "jenkins-master-vol" {
  availability_zone = "eu-west-2a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "jenkins-master-vol"
  }
}

resource "aws_volume_attachment" "jenkins-master-vol-attachment" {
  device_name  = "/dev/xvdh"
  volume_id    = aws_ebs_volume.jenkins-master-vol.id
  instance_id  = aws_instance.jenkins-master.id
  force_detach = true
}


