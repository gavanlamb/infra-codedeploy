provider "aws" {
  region  = var.region
  
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Platform"
      ManagedBy = "Terraform"
      Environment = var.environment
    }
  }
}
provider "aws" {
  alias = "shared"
  assume_role {
    role_arn = var.shared_account_provider_role_arn
  }
}