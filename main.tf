# Internet Gateway
resource "aws_internet_gateway" "vprofile_igw" {
  vpc_id = aws_vpc.vprofile_vpc.id

  tags = {
    Name = "vprofile-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vprofile_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub1-us-east1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vprofile_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub2-us-east1b"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vprofile_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "priv-sub1-us-east1a"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vprofile_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "priv-sub2-us-east1b"
  }
}

# NAT Gateways and Elastic IPs
resource "aws_eip" "nat_eip_1" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "nat-gw-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "nat-gw-2"
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vprofile_igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }

  tags = {
    Name = "private-rt-1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }

  tags = {
    Name = "private-rt-2"
  }
}



# Security Group for Application Load Balancer
resource "aws_security_group" "loadbalancer_sg" {
  vpc_id = aws_vpc.vprofile_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-SG"
  }
}

# Autoscaling Group and Launch Template configurations remain the same as previously shown

# CloudWatch Log Group for AppTier Instances
resource "aws_cloudwatch_log_group" "app_tier_logs" {
  name = "/vprofile/app-tier"
}

# Route53 DNS Record Update (not fully configured, provide your specific details)
# Example for updating Route53 with backend private IP
# Use aws_route53_record resource to update the DNS record

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vprofile_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
   
  }

  tags = {
    Name = "bastion-SG"
  }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.vprofile_vpc.id

  # Ingress rules for MySQL
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instances_sg.id]
  }

  # Ingress rules for Memcache
  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.instances_sg.id]
  }

  # Ingress rules for RabbitMQ
  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.instances_sg.id]
  }

  # Ingress rules for AppTier SG
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  # Egress rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
   
  }

  tags = {
    Name = "backend-SG"
  }
}

resource "aws_security_group" "instances_sg" {
  vpc_id = aws_vpc.vprofile_vpc.id

  # Ingress rules for SSH (from bastion SG)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  tags = {
    Name = "instances-SG"
  }
}

resource "aws_security_group" "apptier_sg" {
  vpc_id = aws_vpc.vprofile_vpc.id

  # Ingress rules for HTTP (from load balancer SG)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  # Ingress rules for SSH (from bastion SG)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  tags = {
    Name = "AppTier-SG"
  }
}

# Bastion Host
resource "aws_instance" "bastion_host" {
  ami                         = "ami-09634e8f6f4163b0e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion Host"
  }
}

# EC2 Instances
resource "aws_instance" "mysql_instance" {
  ami             = "ami-09634e8f6f4163b0e"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.backend_sg.id]

  tags = {
    Name = "MySQL Instance"
  }
}

resource "aws_instance" "memcache_instance" {
  ami             = "ami-09634e8f6f4163b0e"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.backend_sg.id]

  tags = {
    Name = "Memcache Instance"
  }
}

resource "aws_instance" "rabbitmq_instance" {
  ami             = "ami-09634e8f6f4163b0e"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.backend_sg.id]

  tags = {
    Name = "RabbitMQ Instance"
  }
}

resource "aws_instance" "apptier_instance" {
  ami             = "ami-09634e8f6f4163b0e"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_subnet_2.id
  security_groups = [aws_security_group.apptier_sg.id]

  tags = {
    Name = "AppTier Instance"
  }

}
# Autoscaling Groups and Launch Templates (not fully configured, provide your specific details)
# Example for MySQL instance autoscaling group
resource "aws_launch_template" "mysql_lt" {
  name_prefix   = "mysql-lt-"
  image_id      = aws_instance.mysql_instance.ami
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "MySQL Instance"
    }
  }
}

resource "aws_autoscaling_group" "mysql_asg" {
  launch_template {
    id      = aws_launch_template.mysql_lt.id
    version = "$Latest"
  }

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
}
