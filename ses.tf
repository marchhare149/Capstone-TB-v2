
resource "aws_ses_domain_identity" "domain" {
  domain = var.ses_domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "${var.ses_mail_from_subdomain}.${var.ses_domain}"
}

output "ses_verification_token" {
  value = aws_ses_domain_identity.domain.verification_token
}

output "ses_dkim_tokens" {
  value = aws_ses_domain_dkim.dkim.dkim_tokens
}

output "ses_mail_from_domain" {
  value = aws_ses_domain_mail_from.mail_from.mail_from_domain
}