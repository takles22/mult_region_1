terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "aws" {
  region = var.region_2
  profile = var.profile_2
}

provider "aws" {
  alias = "west"
  region = var.region_1
  profile = var.profile_1
}

provider "null" {
  # Configuration options
}