variable "vpc_cidr_block_config" {
    type = string
}

variable "subnet_config" {
    type = map(object({
        cidr_block = string
        availability_zone = string
        map_public_ip_on_launch = bool
    }))
}

variable "nat_gateway_subnet_name_config" {
    type = string
}

variable "networkfirewall_subnet_name_config" {
    type = string
}

variable "endpoint_config" {
    type = map(object({
        vpc_endpoint_type = string
    }))
}
