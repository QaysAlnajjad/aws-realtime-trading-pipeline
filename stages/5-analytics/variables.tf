variable "athena_results_bucket_config" {
  description = "S3 bucket for Athena query results"
  type = string
}

variable "glue_database_name_config" {
  description = "Glue database name"
  type = string
}

variable "glue_crawler_name_config" {
  description = "Glue crawler name"
  type = string
}

variable "athena_workgroup_name_config" {
  description = "Athena workgroup name"
  type = string
}