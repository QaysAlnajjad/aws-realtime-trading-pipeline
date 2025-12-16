data "terraform_remote_state" "stream_state" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key = "stages/data-streaming/terraform.tfstate"
    region = var.state_bucket_region
  }
}

module "athena_s3_bucket" {
  source = "../../modules/s3"
  s3_bucket_name = var.athena_results_s3_bucket_name
  bucket_versioning = "Enabled"
}

module "analytics" {
  source = "../../modules/analytics"
  # S3 buckets
  data_stream_s3_bucket_id = data.terraform_remote_state.stream_state.outputs.data_stream_s3_bucket_id
  athena_results_s3_bucket_id = module.athena_s3_bucket.s3_bucket_id
  # Analytics configuration
  glue_database_name = var.glue_database_name
  glue_crawler_name = var.glue_crawler_name
  athena_workgroup_name = var.athena_workgroup_name
}