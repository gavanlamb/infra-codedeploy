provider "aws" {
  region  = var.region
  
  assume_role {
    role_arn = "arn:aws:iam::258593516853:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Platform"
      ManagedBy = "Terraform"
    }
  }
}
provider "aws" {
  alias = "shared-production"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::556018441473:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Shared"
      ManagedBy = "Terraform"
      Environment = "Production"
    }
  }
}
provider "aws" {
  alias = "shared-preview"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::151170476258:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Shared"
      ManagedBy = "Terraform"
      Environment = "Preview"
    }
  }
}
provider "aws" {
  alias = "time-production"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::104633789203:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Time"
      ManagedBy = "Terraform"
      Environment = "Production"
    }
  }
}
provider "aws" {
  alias = "time-preview"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::829991159560:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Time"
      ManagedBy = "Terraform"
      Environment = "Preview"
    }
  }
}
provider "aws" {
  alias = "user-production"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::266556396524:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "User"
      ManagedBy = "Terraform"
      Environment = "Production"
    }
  }
}
provider "aws" {
  alias = "user-preview"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::172837312601:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "User"
      ManagedBy = "Terraform"
      Environment = "Preview"
    }
  }
}
provider "aws" {
  alias = "networking-production"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::087484524822:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Networking"
      ManagedBy = "Terraform"
      Environment = "Production"
    }
  }
}
provider "aws" {
  alias = "networking-preview"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::365677886296:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Networking"
      ManagedBy = "Terraform"
      Environment = "Preview"
    }
  }
}
provider "aws" {
  alias = "platform-production"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::217292076671:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Platform"
      ManagedBy = "Terraform"
      Environment = "Production"
    }
  }
}
provider "aws" {
  alias = "platform-preview"
  region  = var.region

  assume_role {
    role_arn = "arn:aws:iam::537521289459:role/terraform.infrastructure"
  }
  default_tags {
    tags = {
      Application = "Expensely"
      Team = "Platform"
      ManagedBy = "Terraform"
      Environment = "Preview"
    }
  }
}

variable "azure_devops_org_service_url" {
  type = string
}
variable "azure_devops_personal_access_token" {
  type = string
}
provider "azuredevops" {
  org_service_url = var.azure_devops_org_service_url
  personal_access_token = var.azure_devops_personal_access_token
}
