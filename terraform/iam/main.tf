# Additional IAM roles that might be needed globally
# for Jenkins CI/CD instance to access S3 or ECR

resource "aws_iam_role" "jenkins_role" {
  name = "${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.jenkins_role.name
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.environment}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}
