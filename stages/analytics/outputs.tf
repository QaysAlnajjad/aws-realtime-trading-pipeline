output "athena_results_S3_bucket_id" {
  value = module.athena_s3_bucket.s3_bucket_id
}

output "glue_database_name" {
  value = module.analytics.glue_database_name
}

output "glue_crawler_name" {
  value = module.analytics.glue_crawler_name
}

output "athena_workgroup_name" {
  value = module.analytics.athena_workgroup_name
}
