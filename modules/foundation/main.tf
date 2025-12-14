data "aws_region" "current" {}


//==================================================================================================================================================
//                                                                       VPC, Subnets, NAt
//==================================================================================================================================================

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    # enable DNS for endpoints
    enable_dns_hostnames = true  
    enable_dns_support   = true 
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

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = { Name = "Kinesis-IGW" }
}

resource "aws_eip" "nat_gateway_eip" {
    domain = "vpc"
    tags = { Name = "NAT-gateway-eip" }
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_gateway_eip.id
    subnet_id = aws_subnet.main[var.nat_gateway_subnet_name].id
    depends_on = [aws_internet_gateway.igw]
    tags = { Name = "NAT-gateway" }
}


//==================================================================================================================================================
//                                                                       Route Tables
//==================================================================================================================================================

locals {
  route_tables = {
    private = {
      vpc_endpoint_id = one(one(aws_networkfirewall_firewall.network_firewall.firewall_status).sync_states).attachment[0].endpoint_id
    }
    public = {
      gateway_id = aws_internet_gateway.igw.id
    }
    firewall = {
      nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
  }
}

resource "aws_route_table" "main" {
  for_each = local.route_tables
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        vpc_endpoint_id = lookup(each.value, "vpc_endpoint_id", null)
        gateway_id = lookup(each.value, "gateway_id", null)
        nat_gateway_id = lookup(each.value, "nat_gateway_id", null)
    }
    
    tags = { Name = "${each.key}-route-table" }
}

# NAT Gateway subnet gets direct IGW access
resource "aws_route_table_association" "nat_gateway_route_table_association" {
    subnet_id = aws_subnet.main[var.nat_gateway_subnet_name].id
    route_table_id = aws_route_table.main["public"].id
}

# Firewall subnet routes to NAT Gateway
resource "aws_route_table_association" "firewall_route_table_association" {
    subnet_id = aws_subnet.main[var.networkfirewall_subnet_name].id
    route_table_id = aws_route_table.main["firewall"].id
}

resource "aws_route_table_association" "private_route_table_associations" {
    for_each = {
        for k, v in aws_subnet.main : k => v
        if v.map_public_ip_on_launch == false && k != var.networkfirewall_subnet_name
    }
        subnet_id = each.value.id
        route_table_id = aws_route_table.main["private"].id
}


//==================================================================================================================================================
//                                                                     Network Firewall
//==================================================================================================================================================

resource "aws_networkfirewall_rule_group" "docker_hub_whitelisted" {
    capacity = 100
    name = "docker-hub-whitelisted"
    type = "STATEFUL"

    rule_group {
      rules_source {
        rules_source_list {
          generated_rules_type = "ALLOWLIST"
          target_types = ["TLS_SNI", "HTTP_HOST"]
          targets = [
            "registry-1.docker.io",
            "auth.docker.io", 
            "production.cloudflare.docker.com",
            "index.docker.io",
            "docker.io",
            "registry.docker.io"
          ]
        }
      }
    }
  
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "kinesis-firewall-policy"
  
  firewall_policy {
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.docker_hub_whitelisted.arn
    }
    
    stateless_default_actions = ["aws:forward_to_sfe"]          # Forward to Stateful firewall engine
    stateless_fragment_default_actions = ["aws:forward_to_sfe"] # Forward fragmented packets to Stateful engine
  }
}

resource "aws_networkfirewall_firewall" "network_firewall" {
    name = "kinesis-network-firewall"
    firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
    vpc_id = aws_vpc.vpc.id

    subnet_mapping {
      subnet_id = aws_subnet.main[var.networkfirewall_subnet_name].id
    }

    tags = { Name = "kinesis-network-firewall" }
  
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
        service_name = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
        vpc_endpoint_type = each.value.vpc_endpoint_type
        # Interface endpoints use subnets and security groups
        subnet_ids = each.value.vpc_endpoint_type == "Interface" ? [aws_subnet.main["Prv-Sub-1A"].id, aws_subnet.main["Prv-Sub-1B"].id] : null
        security_group_ids = each.value.vpc_endpoint_type == "Interface" ? [aws_security_group.endpoints_sg.id] : null
        private_dns_enabled = each.value.vpc_endpoint_type == "Interface" ? true : null
        # Gateway endpoints use route tables
        route_table_ids = each.value.vpc_endpoint_type == "Gateway" ? [aws_route_table.main["private"].id] : null
        # Policy for VPC endpoints
        policy = null                       # For simplicity - we already have IAM roles on ECS tasks, SGs, private subnets
        tags = { Name = "${each.key}-endpoint" }
}


