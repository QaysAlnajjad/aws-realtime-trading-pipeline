output "vpc_id" {
    value = aws_vpc.vpc.id 
}

output "ecs_subnets_ids" {
    value = local.private_subnet_ids
}

