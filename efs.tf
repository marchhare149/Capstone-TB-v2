resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "efs-sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "efs_ingress_2049" {
  type                     = "ingress"
  security_group_id        = aws_security_group.efs_sg.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wp_sg.id
}

resource "aws_security_group_rule" "efs_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.efs_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_efs_file_system" "wp" {
  creation_token = "wp-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "private_a" {
  file_system_id  = aws_efs_file_system.wp.id
  subnet_id       = aws_subnet.private_a.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "private_b" {
  file_system_id  = aws_efs_file_system.wp.id
  subnet_id       = aws_subnet.private_b.id
  security_groups = [aws_security_group.efs_sg.id]
}