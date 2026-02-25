
output "ses_verification_token" {
  value = aws_ses_domain_identity.domain.verification_token
}

output "ses_dkim_tokens" {
  value = aws_ses_domain_dkim.dkim.dkim_tokens
}

output "ses_mail_from_domain" {
  value = aws_ses_domain_mail_from.mail_from.mail_from_domain
}
variable "ses_from_email" {
  type = string
}

resource "aws_ses_email_identity" "from" {
  email = var.ses_from_email
}