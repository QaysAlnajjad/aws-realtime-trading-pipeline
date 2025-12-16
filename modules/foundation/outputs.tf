output "vpc_id" {
    value = aws_vpc.vpc.id 
}

output "ecs_subnets_ids" {
    value = local.private_subnet_ids
}

output "vpc_endpoint_sg_id" {
    value = aws_security_group.endpoints_sg.id
}
