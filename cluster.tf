resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet.id]
    security_group_ids = [aws_security_group.allow_all_traffic.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_role_policy_attachment]
}