output "lambda_function_arn" {
    value = aws_lambda_function.kinesis_consumer.arn
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.dynamodb_table.name
}

output "dynamodb_table_arn" {
    value = aws_dynamodb_table.dynamodb_table.arn
}
