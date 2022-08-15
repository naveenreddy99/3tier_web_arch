terraform {
  backend "s3" {
    bucket = "tes44433355"
    key    = "3tier_web_arch/terraform.tfstate"
    region = var.region
  }
}