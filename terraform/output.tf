output "jenkins_master_ip" {
  value = aws_eip.jenkins-master-ip.public_ip
  description = "Public IP address of Jenkins Master"
}


