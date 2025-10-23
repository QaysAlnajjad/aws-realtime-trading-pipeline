variable "vpc_cidr_block" {
    type = string
}

variable "subnet" {
    type = map(object({
        cidr_block = string
        availability_zone = string
        map_public_ip_on_launch = bool
    }))
}

variable "nat_gateway_subnet_name" {
    type = string
}

variable "networkfirewall_subnet_name" {
    type = string
}

variable "endpoint" {
    type = map(object({
        vpc_endpoint_type = string
    }))
}
