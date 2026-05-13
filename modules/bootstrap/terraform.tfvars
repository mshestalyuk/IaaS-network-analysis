region  = "eu-central-1"
project = "security-lab"

# Optional overrides — leave empty to use defaults
# state_bucket_name = ""
# lock_table_name   = "terraform-locks"

# Set to true only for labs you're willing to wipe
force_destroy = true

tags = {
  Project     = "security-lab"
  Environment = "lab"
  ManagedBy   = "terraform"
  Purpose     = "tfstate-bootstrap"
  Owner       = "Maks Shestalyuk"
}