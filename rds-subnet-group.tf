resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  description = "DB subnet group for RDS"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}
