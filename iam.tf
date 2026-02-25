data "aws_caller_identity" "current" {}

resource "aws_iam_role" "wp_role" {
  name = "${var.project_name}-wp-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "wp_profile" {
  name = "${var.project_name}-wp-profile"
  role = aws_iam_role.wp_role.name
}

resource "aws_iam_policy" "wp_s3_policy" {
  name = "${var.project_name}-wp-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:AbortMultipartUpload",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts"
      ]
      Resource = [
        aws_s3_bucket.media.arn,
        "${aws_s3_bucket.media.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "wp_attach_s3" {
  role       = aws_iam_role.wp_role.name
  policy_arn = aws_iam_policy.wp_s3_policy.arn
}

resource "aws_iam_policy" "wp_ses_policy" {
  name = "${var.project_name}-wp-ses-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "wp_attach_ses" {
  role       = aws_iam_role.wp_role.name
  policy_arn = aws_iam_policy.wp_ses_policy.arn
}

resource "aws_iam_role_policy_attachment" "wp_attach_cw_agent" {
  role       = aws_iam_role.wp_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}