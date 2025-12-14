module "foundation" {
    source = "../../modules/foundation"
    vpc_cidr_block = var.vpc_cidr_block_config
    subnet = var.subnet_config
    nat_gateway_subnet_name = var.nat_gateway_subnet_name_config
    networkfirewall_subnet_name = var.networkfirewall_subnet_name_config
    endpoint = var.endpoint_config
}