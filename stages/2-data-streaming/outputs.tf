output "kinesis_stream_arn" {
    value = module.kinesis_data_stream.kinesis_stream_arn
}

output "kinesis_stream_name" {
    value = module.kinesis_data_stream.kinesis_stream_name
}

output "kinesis_s3_bucket_id" {
    value = module.kinesis_data_stream.kinesis_s3_bucket_id
}