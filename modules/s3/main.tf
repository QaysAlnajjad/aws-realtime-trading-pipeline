resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.bucket_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  dynamic "rule" {
    for_each = var.bucket_lifecycle_rules
    content {
      id = rule.value.id
      status = "Enabled"

      filter { 
        prefix = rule.value.prefix 
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}
