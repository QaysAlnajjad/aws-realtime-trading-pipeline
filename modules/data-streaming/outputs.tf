output "kinesis_stream_arn" {
    value = aws_kinesis_stream.kinesis_data_stream.arn     # For producers
}

output "kinesis_stream_name" {
    value = aws_kinesis_stream.kinesis_data_stream.name    # For producers environment variable, consumers
}
