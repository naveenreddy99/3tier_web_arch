provider "aws" {
  region = var.region
}

terraform {

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.26.0"
    }
  }

  backend "s3" {
    bucket = "tes44433355"
    key    = var.key
    region = var.region
    profile = var.profile
  }
}