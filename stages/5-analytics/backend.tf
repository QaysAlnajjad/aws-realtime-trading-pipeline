terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-kinesis-10-2025"
    key    = "environments/5-analytics.tfstate"
    region = "us-east-1"
    //dynamodb_table = "your-lock-table" # optional, for state locking
  }
}
