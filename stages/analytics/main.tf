data "terraform_remote_state" "stream_state" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-kinesis-10-2025"
    key    = "environments/2-data-streaming.tfstate"
    region = "us-east-1"
  }
}

module "analytics" {
  source = "../../modules/analytics"
  # From data streaming stage
  s3_bucket_id = data.terraform_remote_state.stream_state.outputs.kinesis_s3_bucket_id
  # Analytics configuration
  athena_results_bucket = var.athena_results_bucket_name
  glue_database_name = var.glue_database_name
  glue_crawler_name = var.glue_crawler_name
  athena_workgroup_name = var.athena_workgroup_name
}