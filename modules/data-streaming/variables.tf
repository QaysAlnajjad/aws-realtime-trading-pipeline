variable "s3_bucket_name" {
    description = "Name of S3 bucket for streaming data"
    type = string
}

variable "kinesis_data_stream_name" {
    type = string
}

variable "kinesis_firehose_name" {
    type = string 
}


