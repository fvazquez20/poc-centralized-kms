terraform {
  required_version = ">= 1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34.0"
    }
  }
}

provider "aws" {
  alias  = "aws-use2"
  region = "us-east-2"

  default_tags {
    tags = {
      managed_by = "AFT"
    }
  }
}
