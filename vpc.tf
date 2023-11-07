# # provider
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# # Configure the AWS Provider
# provider "aws" {
#   region = "ap-south-1"
#    access_key = "AKIAWNAPTNMITMNWPYTO"
#   secret_key = "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"
# }

# Create VPC
resource "aws_vpc" "vpc-PCS-ap-south-1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC: PCS-ap-south-1"
  } 
#  name = "PCS_VPC"
}

# Adding Private subnets 

# Setup private subnet
resource "aws_subnet" "aws_PCS_private_subnets_1a" {
  vpc_id     = aws_vpc.vpc-PCS-ap-south-1.id
  cidr_block = "10.0.0.0/24" 
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Subnet-Private : Private Subnet ap-south-1a"
  }
}

resource "aws_subnet" "aws_PCS_private_subnets_1b" {
  vpc_id     = aws_vpc.vpc-PCS-ap-south-1.id
  cidr_block = "10.0.128.0/24" 
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Subnet-Private : Private Subnet ap-south-1b"
  }
}

# creating internet gateway 
resource "aws_internet_gateway" "public_internet_gateway" {
  vpc_id = aws_vpc.vpc-PCS-ap-south-1.id
  tags = {
    Name = "IGW: For PCS demo Project"
  }
}

# creating NAT gateway

resource "aws_eip" "nat_eip" {
  vpc = true
  
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.aws_PCS_private_subnets_1b.id
  tags = {
    "Name" = "Private NAT GW: For PCS Demo Project "
  }
}
# creating route table 
   resource "aws_route_table" "PCS_private_route_table" {
   vpc_id = aws_vpc.vpc-PCS-ap-south-1.id
   depends_on = [aws_nat_gateway.nat_gateway]
   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.nat_gateway.id
   }
   tags = {
     Name = "RT Private: For PCS Demo Project "
   }
 }


 resource "aws_route_table_association" "private_subnet_association_1a" {
   depends_on = [aws_subnet.aws_PCS_private_subnets_1a, aws_route_table.PCS_private_route_table]
   subnet_id      = aws_subnet.aws_PCS_private_subnets_1a.id
   route_table_id = aws_route_table.PCS_private_route_table.id
 }

 
 resource "aws_route_table_association" "private_subnet_association_1b" {
   depends_on = [aws_subnet.aws_PCS_private_subnets_1b, aws_route_table.PCS_private_route_table]
   subnet_id      = aws_subnet.aws_PCS_private_subnets_1b.id
   route_table_id = aws_route_table.PCS_private_route_table.id
 }

 #EC2 Instances Creation 

resource "aws_instance" "webserver1" {
    ami           = "ami-02e94b011299ef128"  # Specify an appropriate AMI ID
    instance_type = "t2.micro"
    tags = {
      Name = "EC2 Public subnet 1"
  }
  #  key_name= "aws_key"
    vpc_security_group_ids = [aws_security_group.sg_vpc_PCS-ap-south-1.id]
    subnet_id              = aws_subnet.aws_PCS_private_subnets_1a.id
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-02e94b011299ef128"
  instance_type          = "t2.micro"
  tags = {
     Name = "EC2 Public subnet 1"
  }
  #key_name= "aws_key"
  vpc_security_group_ids = [aws_security_group.sg_vpc_PCS-ap-south-1.id]
  subnet_id              = aws_subnet.aws_PCS_private_subnets_1b.id
}


#create alb

# resource "aws_lb" "PCS_alb" {
#   name               = "PCS_alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups = [aws_security_group.sg_vpc_PCS-ap-south-1.id]
#   subnets         = [aws_PCS_private_subnets_1a.id, aws_PCS_private_subnets_1b.id]

#   tags = {
#     Name = "PCS_ALB_DEMO"
#   }
# }

# resource "aws_lb_target_group" "PCS_tg" {
#   name     = "myTG"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc-PCS-ap-south-1.id

#   health_check {
#     path = "/"
#     port = "traffic-port"
#   }
# }
# resource "aws_lb_target_group_attachment" "PCS_att1" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.webserver1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "attach2" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.webserver2.id
#   port             = 80
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_lb.PCS_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.tg.arn
#     type             = "forward"
#   }
# }

# output "loadbalancerdns" {
#   value = aws_lb.PCS_alb.dns_name
# }
