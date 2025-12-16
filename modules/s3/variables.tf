variable "s3_bucket_name" {
    type = string
}

variable "bucket_versioning" {
    type = string 
    default = "Disabled" 
}

variable "bucket_lifecycle_rules" {
    type = list(object({
        id = string
        prefix = string
        transitions = list(object({
        days = number
        storage_class = string
        }))
        expiration_days = number
    }))
    default = []
}
