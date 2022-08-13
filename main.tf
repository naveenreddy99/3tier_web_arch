#Create VPC
resource "aws_vpc" "TTA-VPC" {
    cidr_block = "${var.vpc-cidr}"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = {
        Name = "TTA VPC"
    }
}

#Create IGW
resource "aws_internet_gateway" "TTA-IGW" {
    vpc_id = aws_vpc.TTA-VPC.id
    tags = {
      "Name" = "TTA IGW"
    }
 
}

# Create Public Subnet 1
resource "aws_subnet" "Public-subnet-1" {
  vpc_id                  = aws_vpc.TTA-VPC.id
  cidr_block              = "${var.Public-Subnet1-cidr}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "TTA Public Subnet1" 
  }
}

# Create Public Subnet 2
resource "aws_subnet" "Public-subnet-2" {
  vpc_id                  = aws_vpc.TTA-VPC.id
  cidr_block              = "${var.Public-Subnet2-cidr}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "TTA Public Subnet2"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "Private-subnet-1" {
  vpc_id                  = aws_vpc.TTA-VPC.id
  cidr_block              = "${var.Private-Subnet1-cidr}"
  availability_zone       = "${var.az1}"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "TTA Private Subnet1" 
  }
}

# Create Private Subnet 2
resource "aws_subnet" "Private-subnet-2" {
  vpc_id                  = aws_vpc.TTA-VPC.id
  cidr_block              = "${var.Private-Subnet2-cidr}"
  availability_zone       = "${var.az2}"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "TTA Private Subnet2"
  }
}

# Create Route Table and Add Public Route
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.TTA-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TTA-IGW.id
  }
  tags       = {
    Name     = "TTA Public Route Table" 
  }
}

# Associate Public Subnet 1 to "Public Route Table"
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.Public-subnet-1.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Associate Public Subnet 2 to "Public Route Table"
resource "aws_route_table_association" "public-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.Public-subnet-2.id
  route_table_id      = aws_route_table.public-route-table.id
}

#Create EIP
resource "aws_eip" "nat_gateway" {
  vpc = true
}

#Create NGW
resource "aws_nat_gateway" "TTA-NGW" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.Public-subnet-2.id 
  tags = {
      "Name" = "TTA NGW"
  }
}

# Create Private Route Table and Add Private Route
resource "aws_route_table" "private-route-table" {
  vpc_id       = aws_vpc.TTA-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.TTA-NGW.id
  }
  tags       = {
    Name     = "TTA Private Route Table" 
  }
}

# Associate Private Subnet 1 to "private Route Table"
resource "aws_route_table_association" "private-subnet-1-route-table-association" {
  subnet_id           = aws_subnet.Private-subnet-1.id
  route_table_id      = aws_route_table.private-route-table.id
}

#Associate Private Subnet 2 to "private Route Table"
resource "aws_route_table_association" "private-subnet-2-route-table-association" {
  subnet_id           = aws_subnet.Private-subnet-2.id
  route_table_id      = aws_route_table.private-route-table.id
}

#Create  SG for Internet facing
resource "aws_security_group" "Internetfacing-sg" {
  name   = "Internetfacing-sg"
  vpc_id = aws_vpc.TTA-VPC.id

  dynamic "ingress" {
      for_each = local.Internet_ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
      Name = "Internetfacing-SG Dynamic Block"
   }
}

resource "aws_security_group_rule" "Internet_outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.Internetfacing-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#Create SG for Internal facing 
resource "aws_security_group" "Internal-sg" {
  name   = "Internal-sg"
  vpc_id = aws_vpc.TTA-VPC.id

  dynamic "ingress" {
      for_each = local.Internal_ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
      Name = "Internalfacing-SG Dynamic Block"
   }
}

resource "aws_security_group_rule" "Internal_outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.Internal-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#Create SG for Bastian Host
resource "aws_security_group" "Bastian-sg" {
  name   = "Bastian-sg"
  vpc_id = aws_vpc.TTA-VPC.id

  dynamic "ingress" {
      for_each = local.Bastian_ingress_rules

      content {
         description = ingress.value.description
         from_port   = ingress.value.port
         to_port     = ingress.value.port
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
      Name = "Bastian-SG Dynamic Block"
   }
}

resource "aws_security_group_rule" "Bastian_outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.Bastian-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


#Create Bastian Host 
resource "aws_instance" "TTA-Bastian" {
  ami  =  "${var.AMI}"
  instance_type = "t2.micro"
  security_groups    = [aws_security_group.Bastian-sg.id]
  subnet_id = aws_subnet.Public-subnet-1.id
   tags = {
           Name = "Bastian Host"
   }
}

#Create ALB TG
resource "aws_lb_target_group" "TTA-ALB-TG" {
  name        = "TTA-lb-alb-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.TTA-VPC.id
}


###INTERNET FACING LB & ASG####
#Create ALB
resource "aws_lb" "TTA-ALB" {
  name                = "TTA-ALB"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.Internetfacing-sg.id]
  subnets             = [aws_subnet.Public-subnet-1.id, aws_subnet.Public-subnet-2.id]
}

#Create LB Listeners
resource "aws_lb_listener" "TTA-ALB_LISTENER" {
  load_balancer_arn = aws_lb.TTA-ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TTA-ALB-TG.arn
  }
}

#Create Launch Configuration 
resource "aws_launch_configuration" "TTA-LC" {
  image_id = "${var.AMI}"
  instance_type = "t2.micro"
  security_groups    = [aws_security_group.Internetfacing-sg.id]
  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo 'Front End LB Webserver' >> /var/www/html/index.html
              service httpd restart
              EOF
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "TTA-ASG" {
  name                      = "TTA-ASG"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.TTA-LC.name
  vpc_zone_identifier       = [aws_subnet.Public-subnet-1.id, aws_subnet.Public-subnet-2.id]
  tag {
    key                 = "Name"
    value               = "Terraform_EC2_InternetFacing"
    propagate_at_launch = true
  }
}

#Attach ALB-TG to ASG
resource "aws_autoscaling_attachment" "TTA-ASG-LB-TG" {
  autoscaling_group_name = aws_autoscaling_group.TTA-ASG.id
  lb_target_group_arn    = aws_lb_target_group.TTA-ALB-TG.arn
}

#Create Auto Scaling Policy 
resource "aws_autoscaling_policy" "TTA-ASG-Policy" {
  name                   = "TTA-ASG-Policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.TTA-ASG.name
}

#Create Cloud watch Alarm 
resource "aws_cloudwatch_metric_alarm" "TTA-ASG-CWA" {
  alarm_name                = "TTA-ASG-CWA"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.TTA-ASG.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.TTA-ASG-Policy.arn]

}


###INTERNAL LB & ASG####

#Create ALB TG
resource "aws_lb_target_group" "TTA-Internal_ALB-TG" {
  name        = "TTA-Internal-ALB-TG"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.TTA-VPC.id
}

#Create ALB
resource "aws_lb" "TTA-Internal_ALB" {
  name                = "TTA-Internal-ALB"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.Internal-sg.id]
  subnets             = [aws_subnet.Private-subnet-1.id, aws_subnet.Private-subnet-2.id]
}

#Create LB Listeners
resource "aws_lb_listener" "TTA-Internal_ALB_LISTENER" {
  load_balancer_arn = aws_lb.TTA-Internal_ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TTA-Internal_ALB-TG.arn
  }
}

#Create Launch Configuration 
resource "aws_launch_configuration" "TTA-Internal_LC" {
  image_id = "${var.AMI}"
  instance_type = "t2.micro"
  security_groups    = [aws_security_group.Internal-sg.id]
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "TTA-Internal_ASG" {
  name                      = "TTA-Internal_ASG"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.TTA-Internal_LC.name
  vpc_zone_identifier       = [aws_subnet.Private-subnet-1.id, aws_subnet.Private-subnet-2.id]
  tag {
    key                 = "Name"
    value               = "Terraform_Ec2_Internal"
    propagate_at_launch = true
  }
}

#Attach ALB-TG to ASG
resource "aws_autoscaling_attachment" "TTA-Internal_ASG-LB-TG" {
  autoscaling_group_name = aws_autoscaling_group.TTA-Internal_ASG.id
  lb_target_group_arn    = aws_lb_target_group.TTA-Internal_ALB-TG.arn
}

#Create Auto Scaling Policy 
resource "aws_autoscaling_policy" "TTA-Internal_ASG-Policy" {
  name                   = "TTA-ASG-Policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.TTA-Internal_ASG.name
}

#Create Cloud watch Alarm 
resource "aws_cloudwatch_metric_alarm" "TTA-Internal_ASG-CWA" {
  alarm_name                = "TTA-Internal_ASG-CWA"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.TTA-Internal_ASG.name
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.TTA-Internal_ASG-Policy.arn]

}

#Create RDS 
resource "aws_db_subnet_group" "RDS" {
  name       = "rdssg"
  subnet_ids = [aws_subnet.Private-subnet-1.id, aws_subnet.Private-subnet-2.id]
}

resource "aws_db_instance" "TTA_RDS" {
  allocated_storage    = 20
  engine               = "mariadb"
  #engine_version       = "10.6.8"
  instance_class       = "db.t2.micro"
  db_name              = "TTARDS"
  username             = "TTA"
  password             = "TTARDSttsrds"
  backup_retention_period = 7
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.Internal-sg.id]
  db_subnet_group_name = aws_db_subnet_group.RDS.name
}

#resource "aws_db_instance_automated_backups_replication" "RDS_Backup" {
#  source_db_instance_arn = aws_db_instance.TTA_RDS.arn
#  retention_period       = 7
#}
 
#Create RDS Replica
resource "aws_db_instance" "TTA__Replica_RDS" {
 replicate_source_db = aws_db_instance.TTA_RDS.arn
 instance_class       = "db.t2.micro"
 skip_final_snapshot  = true
 vpc_security_group_ids = [aws_security_group.Internal-sg.id]
 db_subnet_group_name = aws_db_subnet_group.RDS.name
}