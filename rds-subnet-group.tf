resource "aws_db_subnet_group" "db_subnet_group_v1" {
  name       = "db-subnet-group"
  description = "DB subnet group for RDS"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    name = "db-subnet-group-v1"
  }
}
