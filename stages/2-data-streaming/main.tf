module "kinesis_data_stream" {
    source = "../../modules/data-streaming"
    s3_bucket_name = var.s3_bucket_name_config
    kinesis_data_stream_name = var.kinesis_data_stream_name_config
    kinesis_firehose_name = var.kinesis_firehose_name_config
}