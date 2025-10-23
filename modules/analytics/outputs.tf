output "glue_database_name" {
  value = aws_glue_catalog_database.trading_database.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.trading_crawler.name
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.trading_workgroup.name
}

output "athena_results_bucket" {
  value = aws_s3_bucket.athena_results.bucket
}