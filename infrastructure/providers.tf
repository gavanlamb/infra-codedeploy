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
  alias = "shared.production"
  assume_role {
    role_arn = "arn:aws:iam::556018441473:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "shared.preview"
  assume_role {
    role_arn = "arn:aws:iam::151170476258:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "kronos.production"
  assume_role {
    role_arn = "arn:aws:iam::04633789203:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "kronos.preview"
  assume_role {
    role_arn = "arn:aws:iam::829991159560:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "user.production"
  assume_role {
    role_arn = "arn:aws:iam::266556396524:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "user.preview"
  assume_role {
    role_arn = "arn:aws:iam::172837312601:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "networking.production"
  assume_role {
    role_arn = "arn:aws:iam::087484524822:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "networking.preview"
  assume_role {
    role_arn = "arn:aws:iam::365677886296:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "platform.production"
  assume_role {
    role_arn = "arn:aws:iam::217292076671:role/terraform.infrastructure"
  }
}
provider "aws" {
  alias = "platform.preview"
  assume_role {
    role_arn = "arn:aws:iam::537521289459:role/terraform.infrastructure"
  }
}