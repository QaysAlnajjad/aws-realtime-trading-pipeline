data "terraform_remote_state" "stream_state" {
    backend = "s3"
    config = {
      bucket = var.state_bucket_name
      key = "stages/data-streaming/terraform.tfstate"
      region = var.state_bucket_region
    }      
}

module "consumer" {
    source = "../../modules/consumers"
    # From data streaming stage
    kinesis_stream_arn = data.terraform_remote_state.stream_state.outputs.kinesis_stream_arn
    data_stream_s3_bucket_id = data.terraform_remote_state.stream_state.outputs.data_stream_s3_bucket_id
    # Consumer configuration
    lambda_function_name = var.lambda_function_name
    dynamodb_table_name = var.dynamodb_table_name
}