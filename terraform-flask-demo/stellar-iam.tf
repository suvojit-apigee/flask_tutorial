resource "aws_iam_user" "stellar_devops_user" {
  name = "stellar-devops-user"
}

resource "aws_iam_access_key" "stellar_devops_access_key" {
  user = aws_iam_user.stellar_devops_user.name
}

output "access_key_id" {
  value     = aws_iam_access_key.stellar_devops_access_key.id
  sensitive = true
}

output "secret" {
  value     = aws_iam_access_key.stellar_devops_access_key.encrypted_secret
  sensitive = true
}

resource "aws_iam_user_group_membership" "stellar_devops_user_membership" {
  user   = aws_iam_user.stellar_devops_user.name
  groups = [aws_iam_group.stellar-devops-group.name]
}

resource "aws_iam_group" "stellar-devops-group" {
  name = "stellar-devops-group"
}

data "aws_iam_policy_document" "stellar_devops_role_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "stellar_devops_role" {
  name               = "stellar_devops_role"
  assume_role_policy = data.aws_iam_policy_document.stellar_devops_role_document.json
}

data "aws_iam_policy_document" "aws_s3_bucket_access_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [aws_s3_bucket.stellar_bucket.arn, "${aws_s3_bucket.stellar_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "stellar-bucket-policy"
  description = "Policy to allow access to Stellar S3 bucket as mount point from EC2 instances"
  policy      = data.aws_iam_policy_document.aws_s3_bucket_access_document.json
}

resource "aws_iam_policy_attachment" "stellar-user-role-policy-attach" {
  name       = "stellar-user-role-policy-attachment"
  users      = [aws_iam_user.stellar_devops_user.name]
  roles      = [aws_iam_role.stellar_devops_role.name]
  groups     = [aws_iam_group.stellar-devops-group.name]
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

resource "aws_iam_instance_profile" "stellar_devops_instance_profile" {
  name = "stellar_devops_instance_profile"
  role = aws_iam_role.stellar_devops_role.name
}