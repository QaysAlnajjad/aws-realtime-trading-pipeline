data "aws_region" "current" {}


//==================================================================================================================================================
//                                                                      VPC, Subnets
//==================================================================================================================================================

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    # enable DNS for endpoints
    enable_dns_hostnames = true  
    enable_dns_support = true 
    tags = {
        Name = "Kinesis-VPC"
    }
}

resource "aws_subnet" "main" {
    for_each = var.subnet       
        vpc_id = aws_vpc.vpc.id
        cidr_block = each.value.cidr_block
        availability_zone = each.value.availability_zone
        map_public_ip_on_launch = each.value.map_public_ip_on_launch
        tags = {
            Name = "${each.key}"
        }
}

locals {
  private_subnet_ids = [
    for s in aws_subnet.main :
    s.id if !s.map_public_ip_on_launch
  ]
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = { Name = "Kinesis-IGW" }
}


//==================================================================================================================================================
//                                                                       Route Tables
//==================================================================================================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "private-rt" }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in aws_subnet.main : k => v
    if v.map_public_ip_on_launch
  }

  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for idx, subnet_id in local.private_subnet_ids :
    idx => subnet_id
  }

  subnet_id = each.value
  route_table_id = aws_route_table.private.id
}


//==================================================================================================================================================
//                                                                     Endpoints
//==================================================================================================================================================

resource "aws_security_group" "endpoints_sg" {
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = [aws_vpc.vpc.cidr_block]
    }
    tags = { Name = "endpoints-sg" }
}

resource "aws_vpc_endpoint" "main" {
    for_each = var.endpoint
        vpc_id = aws_vpc.vpc.id
        service_name = "com.amazonaws.${data.aws_region.current.id}.${each.key}"
        vpc_endpoint_type = each.value.vpc_endpoint_type
        # Interface endpoints use subnets and security groups
        subnet_ids = each.value.vpc_endpoint_type == "Interface" ? local.private_subnet_ids : null
        security_group_ids = each.value.vpc_endpoint_type == "Interface" ? [aws_security_group.endpoints_sg.id] : null
        private_dns_enabled = each.value.vpc_endpoint_type == "Interface" ? true : null
        # Gateway endpoints use route tables
        route_table_ids = each.value.vpc_endpoint_type == "Gateway" ? [aws_route_table.private.id] : null
        # Policy for VPC endpoints
        policy = null                       # For simplicity - we already have IAM roles on ECS tasks, SGs, private subnets
        tags = { Name = "${each.key}-endpoint" }
}


