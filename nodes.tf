# Worker nodes launch configuration
resource "aws_launch_template" "eks_launch_configuration" {
  name          = "eks-launch-configuration"
  image_id      = "ami-0e2c8caa4b6378d8c" # Replace with the latest Amazon EKS optimized AMI
  instance_type = "t3.medium"
  security_groups = [aws_security_group.allow_all_traffic.id]
  iam_instance_profile = aws_iam_instance_profile.eks_node_instance_profile.id

  lifecycle {
    create_before_destroy = true
  }
}

# Auto scaling group for worker nodes
resource "aws_autoscaling_group" "eks_node_group" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.eks_subnet.id]
  launch_configuration = aws_launch_configuration.eks_launch_configuration.id
}

# IAM Instance Profile for worker nodes
resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "eks-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}