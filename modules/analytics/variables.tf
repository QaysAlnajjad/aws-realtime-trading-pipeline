variable "s3_bucket_id" {
  description = "S3 bucket containing trading data"
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

variable "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  type = string
}