# We Created an internet gateway
resource "aws_internet_gateway" "exam_igw" {
  vpc_id = aws_vpc.exam_vpc.id

  tags = {
    Name = "exam_IGW"
  }
}

# Define an AWS route table for public subnet 1
resource "aws_route_table" "exam_route_table1" {
  vpc_id = aws_vpc.exam_vpc.id

  tags = {
    Name = "Exam_RT1"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.exam_igw.id
  }
}

# Associate the route table with public subnet 1
resource "aws_route_table_association" "route_table_association1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.exam_route_table1.id
}

# Define a second association of the route table with public subnet 2
resource "aws_route_table_association" "route_table_association2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.exam_route_table2.id
}

# Define an AWS route table for public subnet 2
resource "aws_route_table" "exam_route_table2" {
  vpc_id     = aws_vpc.exam_vpc.id
  depends_on = [aws_nat_gateway.exam_natgw]

  tags = {
    Name = "Exam_RT2"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.exam_natgw.id
  }
}

# Associate the route table with private subnet 1
resource "aws_route_table_association" "route_table_association3" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.exam_route_table2.id
}

# Associate the route table with private subnet 2
resource "aws_route_table_association" "route_table_association4" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.exam_route_table2.id
}

# Define an Elastic IP (EIP) for NAT gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.exam_igw]

  tags = {
    Name = "EIP_vpc"
  }
}

# Define a NAT gateway using the EIP
resource "aws_nat_gateway" "exam_natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.exam_igw]
}

# Retrieve available AWS availability zones
data "aws_availability_zones" "available" {}

# Define an AWS Application Load Balancer (ALB)
resource "aws_lb" "exam_elb" {
  name                             = "exam-elb"
  internal                         = false
  load_balancer_type               = "application"
  enable_deletion_protection       = false
  subnets                          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_http2                     = true
  #security_groups                  = [aws_security_group.mydbsecurity.id]
  enable_cross_zone_load_balancing = true
}

# Define an AWS ALB listener
resource "aws_lb_listener" "exam_elb_listener" {
  load_balancer_arn = aws_lb.exam_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

# Define an AWS ALB target group
resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.exam_vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Define a rule for the ALB listener
resource "aws_lb_listener_rule" "my_listener_rule" {
  listener_arn = aws_lb_listener.exam_elb_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
# Created an IAM role for EC2 instances 
resource "aws_iam_role" "ec2_role" {
  name = "ec2_instance_role"
  
  # Attached the necessary policies to the role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Created an IAM instance profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Define a list of subnet IDs
locals {
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Create EC2 instances
resource "aws_instance" "exam_instance" {
  count                   = 1
  ami                     = "ami-008bcc0a51a849165"
  instance_type           = "t2.micro"
  subnet_id               = local.subnet_ids[count.index]
  iam_instance_profile     = aws_iam_instance_profile.ec2_instance_profile.name
  key_name                = "newkey"
  security_groups         = [aws_security_group.exam_sg.id]
  associate_public_ip_address = true
  user_data = file("user-data.sh")
  tags = {
    Name = "exam${count.index + 1}"
  }
}

# Defined an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "exam_asg" {
  name                 = "exam-asg"
  launch_configuration = aws_launch_configuration.exam_lc.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  target_group_arns    = [aws_lb_target_group.my_target_group.arn]
}
# Defined a Launch Configuration
resource "aws_launch_configuration" "exam_lc" {
  name_prefix          = "exam-lc"
  image_id             = "ami-008bcc0a51a849165"  
  instance_type        = "t2.micro"             
  security_groups      = [aws_security_group.exam_sg.id]
  key_name             = "newkey"              
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

}
# Attached the instances to the ELB
resource "aws_autoscaling_attachment" "exam_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.exam_asg.name
  lb_target_group_arn   = aws_lb_target_group.my_target_group.arn
}


