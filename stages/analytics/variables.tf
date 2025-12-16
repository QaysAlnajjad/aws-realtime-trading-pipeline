variable "athena_results_s3_bucket_name" {
  type = string
}

variable "glue_database_name" {
  description = "Glue database name"
  type = string
}

variable "glue_crawler_name" {
  description = "Glue crawler name"
  type = string
}

variable "athena_workgroup_name" {
  description = "Athena workgroup name"
  type = string
}
