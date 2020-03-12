data "template_file" "init-script" {
  template = file("scripts/init.cfg")
  vars = {
    REGION = var.AWS_REGION
  }
}

data "template_file" "master_bootstrap" {
  template = file("scripts/master_bootstrap.sh")
  vars = {
    DEVICE = var.instance_block_device
  }
}

data "template_file" "jenkins_bootstrap" {
  template = file("scripts/jenkins_bootstrap.sh")

  vars = {
    jenkins_password = var.jenkins_password
  }
}

data "template_file" "worker_bootstrap" {
  template = file("scripts/worker_bootstrap.sh")

  vars = {
    region      = "eu-west-1"
    node_name   = "eu-west-1-jenkins_worker_linux"
    domain      = ""
    device_name = "eth0"
    server_ip   = aws_instance.jenkins-master.private_ip
    worker_key  = file(var.path_private_worker_key)
    jenkins_username = "admin"
    jenkins_password = var.jenkins_password
  }
}

data "template_cloudinit_config" "cloudinit-jenkins-master" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.master_bootstrap.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.jenkins_bootstrap.rendered
  }
}

data "template_cloudinit_config" "cloudinit-jenkins-worker" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.worker_bootstrap.rendered
  }
}

