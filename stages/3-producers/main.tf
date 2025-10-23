data "terraform_remote_state" "foundation_state" {
    backend = "s3"
    config = {
      bucket = "terraform-state-bucket-kinesis-10-2025"
      key    = "environments/1-foundation.tfstate"
      region = "us-east-1"
    }      
}

data "terraform_remote_state" "stream_state" {
    backend = "s3"
    config = {
      bucket = "terraform-state-bucket-kinesis-10-2025"
      key    = "environments/2-data-streaming.tfstate"
      region = "us-east-1"
    }      
}

module "producer" {
    source = "../../modules/producers"
    # From foundation stage
    vpc_id = data.terraform_remote_state.foundation_state.outputs.vpc_id
    ecs_subnets_ids = data.terraform_remote_state.foundation_state.outputs.ecs_subnets_ids
    # From data streaming stage
    kinesis_stream_name = data.terraform_remote_state.stream_state.outputs.kinesis_stream_name
    kinesis_stream_arn = data.terraform_remote_state.stream_state.outputs.kinesis_stream_arn
    # ECS configuration
    ecs_cluster_name = var.ecs_cluster_name_config
    ecs_task_definition_name = var.ecs_task_definition_name_config
    ecs_security_group_name = var.ecs_security_group_name_config
    ecs_service = var.ecs_service_config
    docker_image_uri = var.docker_image_uri_config
}