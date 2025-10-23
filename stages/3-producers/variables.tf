variable "ecs_cluster_name_config" {
  type = string
}

variable "docker_image_uri_config" {
    type = string
}

variable "ecs_task_definition_name_config" {
    type = string
}

variable "ecs_security_group_name_config" {
  type = string
}

variable "ecs_service_config" {
  type = map(object({
    desired_count = number
    launch_type = string
  }))
}

