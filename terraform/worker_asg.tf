##  Key for Workers

resource "aws_key_pair" "worker_pubkey" {
  key_name   = "worker_pubkey"
  public_key = file(var.path_public_worker_key)
}


## Slave ASG

resource "aws_launch_configuration" "worker-launchconfig" {
  name_prefix          = "worker-launchconfig"
  image_id             = data.aws_ami.jenkins_ami.image_id
  instance_type        = var.instance_type["worker"]
  iam_instance_profile = "jenkins_worker"
  key_name             = aws_key_pair.worker_pubkey.key_name
  security_groups      = [aws_security_group.jenkins-master-worker.id]
  user_data            = data.template_cloudinit_config.cloudinit-jenkins-worker.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker-autoscaling" {
  name                      = "worker-autoscaling"
  vpc_zone_identifier       = [aws_subnet.jenkins-private-1.id, aws_subnet.jenkins-private-2.id]
  launch_configuration      = aws_launch_configuration.worker-launchconfig.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "jenkins-worker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

