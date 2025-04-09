
resource "aws_security_group" "jenkins_sg" {

  name        = "jenkins_sg"
  description = "Restrict access to Jenkins"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 8096
    to_port     = 8096
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "ec2_ecr_role" {

  name = "jenkins_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

}


resource "aws_iam_policy" "ecr_full_access" {

  name        = "jenkins_policy"
  description = "Grants full access to Amazon ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DeleteRepository",
        "ecr:BatchDeleteImage",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy",
        "ecr:GetLifecyclePolicy",
        "ecr:PutLifecyclePolicy",
        "ecr:DeleteLifecyclePolicy",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeImageScanFindings",
        "lambda:PublishLayerVersion",
        "lambda:ListLayers",
        "lambda:GetLayerVersion",
        "lambda:DeleteLayerVersion"
      ]
      Resource = "*"
    }]
  })

}


# Attach ECR Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {

  policy_arn = aws_iam_policy.ecr_full_access.arn
  role       = aws_iam_role.ec2_ecr_role.name

}


# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {

  name = "jenkins-iam-profile"
  role = aws_iam_role.ec2_ecr_role.name

}


resource "aws_instance" "jenkins_controller" {

  ami           = var.ami
  instance_type = "t2.large"
  key_name      = var.key_pair
  security_groups = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "Jenkins Controller"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade
              sudo yum install java-17-amazon-corretto -y
              sudo yum install jenkins -y
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              sudo yum update -y
              sudo amazon-linux-extras enable docker
              sudo yum install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker jenkins
              sudo systemctl restart jenkins
              sudo systemctl restart docker
              sudo yum update -y
              sudo yum install git -y
              EOF

}
