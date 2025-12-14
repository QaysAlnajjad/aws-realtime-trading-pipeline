vpc_cidr_block_config = "192.168.0.0/16"

subnet_config = {
  NAT-Subnet = {
    cidr_block = "192.168.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  }
  Firewall-Subnet = {
    cidr_block = "192.168.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false
  }
  Prv-Sub-1A = {
    cidr_block = "192.168.3.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
  }
  Prv-Sub-1B = {
    cidr_block = "192.168.4.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false
  }
}

nat_gateway_subnet_name_config = "NAT-Subnet"

networkfirewall_subnet_name_config = "Firewall-Subnet"

endpoint_config = {
  logs = {
    vpc_endpoint_type = "Interface"
  }
  kinesis-streams = {
    vpc_endpoint_type = "Interface"
  }
  s3 = {
    vpc_endpoint_type = "Gateway"
  }
}
