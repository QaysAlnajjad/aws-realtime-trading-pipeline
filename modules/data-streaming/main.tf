//=========================================================================================================================================
//                                                        Kinesis Data Stream
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


//=========================================================================================================================================
//                                                            Firehose
//=========================================================================================================================================

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

resource "aws_iam_role_policy" "kinesis_firehose_policy" {
    role = aws_iam_role.kinesis_firehose_role.name
    name = "kinesis_firehose_policy"
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
            "arn:aws:s3:::${var.data_stream_s3_bucket_id}",
            "arn:aws:s3:::${var.data_stream_s3_bucket_id}/*"
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
        bucket_arn = "arn:aws:s3:::${var.data_stream_s3_bucket_id}"
        prefix = "raw-data/"
        
        # Whichever comes first triggers the batch: 5 MB is reached OR 5 minutes pass
        buffering_size = 5
        buffering_interval = 300

        compression_format = "GZIP"
     }
}

