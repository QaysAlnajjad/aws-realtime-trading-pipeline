output "kinesis_stream_arn" {
    value = module.kinesis_data_stream.kinesis_stream_arn
}

output "kinesis_stream_name" {
    value = module.kinesis_data_stream.kinesis_stream_name
}

output "data_stream_s3_bucket_id" {
    value = module.data_stream_s3_bucket.s3_bucket_id
}