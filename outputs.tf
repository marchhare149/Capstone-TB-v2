output "alb_dns_name" {
  value = aws_lb.wordpress.dns_name
}
output "efs_id" {
  value = aws_efs_file_system.wp.id
}

output "efs_dns" {
  value = aws_efs_file_system.wp.dns_name
}