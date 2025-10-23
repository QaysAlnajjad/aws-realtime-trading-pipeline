output "lambda_function_arn" {
    value = module.consumer.lambda_function_arn
}

output "dynamodb_table_name" {
    value = module.consumer.dynamodb_table_name
}

output "dynamodb_table_arn" {
  value = module.consumer.dynamodb_table_arn
}