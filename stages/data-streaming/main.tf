module "kinesis_data_stream" {
    source = "../../modules/data-streaming"
    s3_bucket_name = var.s3_bucket_name
    kinesis_data_stream_name = var.kinesis_data_stream_name
    kinesis_firehose_name = var.kinesis_firehose_name
}