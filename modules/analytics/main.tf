//======================================================================================================================================
//                                                        Glue Data Catalog
//======================================================================================================================================

resource "aws_glue_catalog_database" "trading_database" {
  name = var.glue_database_name
  description = "Database for trading data analytics"
}

resource "aws_glue_crawler" "trading_crawler" {
  database_name = aws_glue_catalog_database.trading_database.name
  name = var.glue_crawler_name
  role = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.s3_bucket_id}/raw-data/"
  }

  s3_target {
    path = "s3://${var.s3_bucket_id}/completed-trades/"
  }

  schedule = "cron(0 6 * * ? *)"  # Daily at 6 AM
}

//======================================================================================================================================
//                                                        IAM Role for Glue
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
  name = "glue-s3-access"
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
          "arn:aws:s3:::${var.s3_bucket_id}",
          "arn:aws:s3:::${var.s3_bucket_id}/*"
        ]
      }
    ]
  })
}

//======================================================================================================================================
//                                                        Athena
//======================================================================================================================================

resource "aws_s3_bucket" "athena_results" {
  bucket = var.athena_results_bucket
}

resource "aws_athena_workgroup" "trading_workgroup" {
  name = var.athena_workgroup_name
  state = "ENABLED"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true
    
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
    }
  }
}