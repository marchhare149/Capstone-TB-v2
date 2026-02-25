variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "vockey"
}

variable "project_name" {
  type = string
}

variable "media_bucket_name" {
  type = string
}

variable "site_domain" {
  type    = string
  default = ""
}

variable "ses_mail_from_subdomain" {
  type    = string
  default = "mail"
}

variable "alarm_email" {
  type = string
}

variable "ses_domain" {
  type    = string
  default = ""
}

variable "wp_root" {
  type    = string
  default = "/var/www/html"
}