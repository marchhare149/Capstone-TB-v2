resource "aws_instance" "bastion" {
  ami                    = "ami-0d593311db5abb..."
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  key_name = var.key_name   

  tags = {
    Name = "bastion-host"
  }
}
