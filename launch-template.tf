resource "aws_launch_template" "wordpress" {
  name_prefix   = "wp-lt-"
  image_id      = "ami-0d593311db5abb72b"
  instance_type = "t2.micro"

  key_name  = var.key_name
  user_data = base64encode(file("userdata.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.wp_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.wp_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-asg"
    }
  }
}