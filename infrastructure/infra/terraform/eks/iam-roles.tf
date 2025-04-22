module "iam_roles" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.28.0"

  create_role = true
  role_name   = "agentic-rag-retriever-role"

  provider_url = module.eks.oidc_provider
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:rag-system:retriever-agent"
  ]

  role_policy_arns = {
    s3 = aws_iam_policy.retriever_s3_access.arn
  }
}

resource "aws_iam_policy" "retriever_s3_access" {
  name        = "RetrieverAgentS3Access"
  description = "Least privilege access for Retriever Agent"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::rag-knowledge-base/*",
          "arn:aws:s3:::rag-knowledge-base"
        ]
      }
    ]
  })
}