#########################
# IRSA: IAM Role for Voting App
#########################

# Fetch EKS Cluster Info (needed for OIDC)
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

# OIDC Provider for EKS
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.aws_eks_cluster.cluster.certificate_authority[0].data]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# IAM Role for Kubernetes ServiceAccount (IRSA)
resource "aws_iam_role" "voting_app_irsa" {
  name = "voting-app-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:default:voting-app-sa"
          }
        }
      }
    ]
  })
}

# IAM Policy for Voting App (example: list S3 buckets)
resource "aws_iam_policy" "voting_app_policy" {
  name        = "voting-app-policy"
  description = "Allow the voting app to list S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to IRSA Role
resource "aws_iam_role_policy_attachment" "attach_voting_policy" {
  role       = aws_iam_role.voting_app_irsa.name
  policy_arn = aws_iam_policy.voting_app_policy.arn
}
