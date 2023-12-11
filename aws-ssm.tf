resource "aws_iam_instance_profile" "ec2_ssm_iam_profile" {
  name_prefix = "${var.env}-${var.owner}-ssm-iam-profile"
  role        = aws_iam_role.ec2_ssm_iam_role.name
}
resource "aws_iam_role" "ec2_ssm_iam_role" {
  name_prefix = "${var.env}-${var.owner}-ssm-iam-role"
  description = "The role for the ssm resources EC2"

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

resource "aws_iam_policy" "ec2_ssm_policy" {
  name_prefix = "${var.env}-${var.owner}-ec2-ssm-policy"
  path        = "/"
  description = "Session Manager permissions to an existing IAM role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:*",
          "rds:*",
          "logs:*",
          "ec2messages:*",
          "s3:*"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_iam_role.name
  policy_arn = aws_iam_policy.ec2_ssm_policy.arn
}

resource "aws_kms_key" "ssm_kms_token" {
  description             = "encryption and decryption for session data"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.env}-${var.owner}-ssm-kms-token"
  target_key_id = aws_kms_key.ssm_kms_token.key_id
}
