output "state_bucket" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "state_bucket_arn" {
  description = "ARN of the state bucket"
  value       = aws_s3_bucket.tfstate.arn
}

output "lock_table" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.locks.name
}

output "region" {
  description = "Region where state resources live"
  value       = var.region
}

output "account_id" {
  description = "AWS account ID the bootstrap ran in"
  value       = data.aws_caller_identity.current.account_id
}