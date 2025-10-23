ecs_cluster_name_config = "kinesis-cluster"

ecs_security_group_name_config = "kinesis-producer-tasks-SG" 

docker_image_uri_config = "qaysalnajjad/kinesis-stock-producer:latest"

ecs_task_definition_name_config = "kinesis-producer-task-definition"

ecs_service_config = {
    kinesis-producer-service = {
        desired_count = 1   # Only one producer to not have multiple values for the same stocks at the same time
        launch_type = "FARGATE"
    }
}
