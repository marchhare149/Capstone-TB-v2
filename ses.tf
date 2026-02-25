
variable "ses_from_email" {
  type = string
}

resource "aws_ses_email_identity" "from" {
  email = var.ses_from_email
}