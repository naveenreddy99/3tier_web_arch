# 3-tier Web Architecture



![image](https://user-images.githubusercontent.com/21337806/184484233-eaf17ae7-03f1-47db-8049-85e7be6a5f09.png)


The code for the S3 Bucket creation is here 

###### S3.tf ####
/*==== S3 Bucket ======*/

resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
}

/* Block Public access to S3 Bucket */

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  depends_on = [aws_s3_bucket.bucket]

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


###### variables.tf ####
variable "s3_bucket_name" {
  description = "Bucket Name"
}

variable "region" {
  description = "Region Name"
}


###### provider.tf ####

provider "aws" {
  region = var.region
}
