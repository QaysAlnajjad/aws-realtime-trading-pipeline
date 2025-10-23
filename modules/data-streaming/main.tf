//=========================================================================================================================================
//                                                             S3 bucket
//=========================================================================================================================================

resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.s3_bucket_name
    tags = {
      Name = var.s3_bucket_name
      Description = "S3 bucket for Kinesis data streaming store"
    }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
    bucket = aws_s3_bucket.s3_bucket.id
    versioning_configuration {
      status = "Disabled"
    }  
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access" {
    bucket = aws_s3_bucket.s3_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true  
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle" {
    bucket = aws_s3_bucket.s3_bucket.id

    # Rule for raw streaming data (less critical)
    rule {
      id = "raw_data_lifecycle"
      status = "Enabled"
      filter {
        prefix = "raw-data/"
      }
      transition {
        days = 30
        storage_class = "STANDARD_IA"
      }
      expiration {
        days = 90
      }
    }
    # Rule for trading signals (more valuable)
    rule {
      id = "trading_signals_lifecycle"
      status = "Enabled"
      filter {
        prefix = "trading-signals/"
      }
      # Move to IA after 30 days
      transition {
        days = 30
        storage_class = "STANDARD_IA"
      }
      # Move to Glacier after 90 days 
      transition {
        days = 90
        storage_class = "GLACIER"
      }
      # Delete after 356 days
      expiration {
        days = 356
      }
    }
}


//=========================================================================================================================================
//                                                   Kinesis Data Stream + Firehose
//=========================================================================================================================================

resource "aws_kinesis_stream" "kinesis_data_stream" {
    name = var.kinesis_data_stream_name
    shard_count = 2
    retention_period = 24               # 24 hours (minimum allowed)
    shard_level_metrics = [             # For monitor performance and troubleshoot
        "IncomingRecords",              # Number of records producers send to each shard per minute
        "OutgoingRecords"               # Number of records consumers read from each shard per minute
    ]
    tags = { Name = var.kinesis_data_stream_name}
}

resource "aws_iam_role" "kinesis_firehose_role" {
    name = "kinesis_firehose_role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "firehose.amazonaws.com"
          }
        }
      ]
    })
    tags = { Name = "kinesis_firehose_role" }
}

resource "aws_iam_role_policy" "kinesis_firehose_role_policy" {
    role = aws_iam_role.kinesis_firehose_role.name
    name = "kinesis_firehose_role_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            //"s3:GetObject",
            //"s3:ListBucket",
            //"s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          Resource = [
            aws_s3_bucket.s3_bucket.arn,
            "${aws_s3_bucket.s3_bucket.arn}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
              "kinesis:DescribeStream",
              "kinesis:GetShardIterator",
              "kinesis:GetRecords"
          ]
          Resource = aws_kinesis_stream.kinesis_data_stream.arn
        }
      ]
    })
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose" {
    name = var.kinesis_firehose_name
    destination = "extended_s3"
    kinesis_source_configuration {
      kinesis_stream_arn = aws_kinesis_stream.kinesis_data_stream.arn
      role_arn = aws_iam_role.kinesis_firehose_role.arn
    }
    extended_s3_configuration {
        role_arn = aws_iam_role.kinesis_firehose_role.arn
        bucket_arn = aws_s3_bucket.s3_bucket.arn
        prefix = "raw-data/"
        
        # Whichever comes first triggers the batch:
        buffering_size = 5
        buffering_interval = 300

        compression_format = "GZIP"
     }
}

