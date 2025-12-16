//======================================================================================================================================
//                                                        Glue Data Catalog
//======================================================================================================================================

resource "aws_glue_catalog_database" "trading_database" {
  name = var.glue_database_name
  description = "Database for trading data analytics"
}


//======================================================================================================================================
//                                                          Glue Crawler
//======================================================================================================================================

resource "aws_iam_role" "glue_role" {
  name = "glue-crawler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "glue-s3-policy"
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_stream_s3_bucket_id}",
          "arn:aws:s3:::${var.data_stream_s3_bucket_id}/*"
        ]
      }
    ]
  })
}

resource "aws_glue_crawler" "trading_crawler" {
  name = var.glue_crawler_name
  database_name = aws_glue_catalog_database.trading_database.name
  role = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.data_stream_s3_bucket_id}/raw-data/"
  }

  s3_target {
    path = "s3://${var.data_stream_s3_bucket_id}/completed-trades/"
  }

  schedule = "cron(0 6 * * ? *)"  # Daily at 6 AM
}


//======================================================================================================================================
//                                                        Athena
//======================================================================================================================================
/*
resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  versioning_configuration {
    status = "Enabled"
  }
}
*/

resource "aws_athena_workgroup" "trading_workgroup" {
  name = var.athena_workgroup_name
  state = "ENABLED"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true
    
    result_configuration {
      output_location = "s3://${var.athena_results_s3_bucket_id}/"
    }
  }
}