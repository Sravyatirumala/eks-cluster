# EKS Cluster Role
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-demo"
  tags = {
    tag-key = "eks-cluster-demo"
  }

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# EKS Cluster Policy Attachment
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Custom Policy for EKS Cluster Access
resource "aws_iam_policy" "eks_custom_access" {
  name        = "EKSDescribeAccess"
  description = "Custom EKS read-only access policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the custom policy to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks-custom-access-attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_custom_access.arn
}

# EKS Worker Node Role
resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach AmazonEKSWorkerNodePolicy to Node Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Attach AmazonEKS_CNI_Policy to Node Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Attach AmazonEC2ContainerRegistryReadOnly to Node Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Custom EBS Permissions for EKS Nodes
resource "aws_iam_policy" "nodes-ebs-policy" {
  name        = "EKSNodeEBSPolicy"
  description = "EBS permissions for EKS node group"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DescribeVolumes",
          "ec2:DeleteVolume"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the Custom EBS Policy to Node Role
resource "aws_iam_role_policy_attachment" "nodes-ebs-policy-attachment" {
  policy_arn = aws_iam_policy.nodes-ebs-policy.arn
  role       = aws_iam_role.nodes.name
}

# Optional: Attach AmazonS3ReadOnlyAccess to allow access to S3 buckets for the nodes (if needed)
resource "aws_iam_role_policy_attachment" "nodes-AmazonS3ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.nodes.name
}
