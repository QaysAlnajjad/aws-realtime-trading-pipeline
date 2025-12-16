module "data_stream_s3_bucket" {
    source = "../../modules/s3"
    s3_bucket_name = var.data_stream_s3_bucket_name
    bucket_lifecycle_rules = var.bucket_lifecycle_rules_config
}

module "kinesis_data_stream" {
    source = "../../modules/data-streaming"
    data_stream_s3_bucket_id = module.data_stream_s3_bucket.s3_bucket_id
    kinesis_data_stream_name = var.kinesis_data_stream_name
    kinesis_firehose_name = var.kinesis_firehose_name
}