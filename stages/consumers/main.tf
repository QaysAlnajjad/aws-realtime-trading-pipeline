data "terraform_remote_state" "stream_state" {
    backend = "s3"
    config = {
      bucket = "terraform-state-bucket-kinesis-10-2025"
      key    = "environments/2-data-streaming.tfstate"
      region = "us-east-1"
    }      
}

module "consumer" {
    source = "../../modules/consumers"
    # From data streaming stage
    kinesis_stream_arn = data.terraform_remote_state.stream_state.outputs.kinesis_stream_arn
    s3_bucket_id = data.terraform_remote_state.stream_state.outputs.kinesis_s3_bucket_id
    # Consumer configuration
    lambda_function_name = var.lambda_function_name
    dynamodb_table_name = var.dynamodb_table_name
}