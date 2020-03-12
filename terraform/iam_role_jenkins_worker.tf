resource "aws_iam_instance_profile" "jenkins_worker" {
  name = "jenkins_worker"
  role = aws_iam_role.jenkins_worker.name
}

resource "aws_iam_role" "jenkins_worker" {
  name = "jenkins_worker"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
