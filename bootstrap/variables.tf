variable "region" {
  description = "AWS region for the state bucket and lock table"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name, used as a prefix for resource names"
  type        = string
  default     = "security-lab"
}

variable "state_bucket_name" {
  description = "Override for the state bucket name. If empty, defaults to <project>-tfstate-<account-id>."
  type        = string
  default     = ""
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "enable_versioning" {
  description = "Enable versioning on the state bucket (recommended)"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow the state bucket to be destroyed even if it contains objects. Useful for labs; set to false in production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "security-lab"
    Environment = "lab"
    ManagedBy   = "terraform"
    Purpose     = "tfstate-bootstrap"
  }
}