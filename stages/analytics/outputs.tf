output "glue_database_name" {
  value = module.analytics.glue_database_name
}

output "glue_crawler_name" {
  value = module.analytics.glue_crawler_name
}

output "athena_workgroup_name" {
  value = module.analytics.athena_workgroup_name
}

output "athena_results_bucket" {
  value = module.analytics.athena_results_bucket
}