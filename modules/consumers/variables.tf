variable "kinesis_stream_arn" {
    type = string
}

variable "s3_bucket_id" {
    type = string
}

variable "lambda_function_name" {
    type = string
}

variable "dynamodb_table_name" {
    type = string
}

variable "lambda_policies" {
    type = map(object({
        is_aws_managed = bool
        policy_document = optional(object({
            actions = list(string)
            resources = list(string)
        }))
        aws_policy_arn = optional(string)
    }))
    default = {
      "basic-execution" = {
        is_aws_managed = true
        aws_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      }
      "kinesis-access" = {
        is_aws_managed = false
        policy_document = {
          actions = ["kinesis:DescribeStream", "kinesis:GetShardIterator", "kinesis:GetRecords", "kinesis:ListStreams"]
          resources = []       # Will be populated dynamically
        }
      }
      "dynamodb-access" = {
        is_aws_managed = false
        policy_document = {
          actions = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan"]
          resources = []       # Will be populated dynamically
        }
      }
      "s3-access" = {
        is_aws_managed = false
        policy_document = {
          actions = ["s3:PutObject", "s3:PutObjectAcl"]
          resources = []       # Will be populated dynamically
        }
      }
    }
}