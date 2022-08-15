variable "region" {
  default     = "us-east-1"
  description = "Region"
  type        = string
}

variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
  type        = string
}

variable "Public-Subnet1-cidr" {
  default     = "10.0.1.0/24"
  description = "Public Subnet 1 CIDR block"
  type        = string
}

variable "Public-Subnet2-cidr" {
  default     = "10.0.2.0/24"
  description = "Public Subnet 2 CIDR block"
  type        = string
}

variable "Private-Subnet1-cidr" {
  default     = "10.0.3.0/24"
  description = "Private Subnet 1 CIDR block"
  type        = string
}

variable "Private-Subnet2-cidr" {
  default     = "10.0.4.0/24"
  description = "Private Subnet 2 CIDR block"
  type        = string
}

variable "az1" {
  default     = "us-east-1a"
  description = "Availability Zone (us-east-1a)"
  type        = string
}

variable "az2" {
  default     = "us-east-1b"
  description = "Availability Zone (us-east-1b)"
  type        = string
}

locals {
  Internet_ingress_rules = [{
    port        = 22
    description = "Ingress rules for port 22"
    },
    {
      port        = 80
      description = "Ingree rules for port 80"
    },
    {
      port        = 443
      description = "Ingree rules for port 443"
  }]
}

locals {
  Internal_ingress_rules = [{
    port        = 22
    description = "Ingress rules for port 22"
    },
    {
      port        = 80
      description = "Ingree rules for port 80"
    },
    {
      port        = 3306
      description = "Ingree rules for port 3306"
  }]
}

locals {
  Bastian_ingress_rules = [{
    port        = 22
    description = "Ingress rules for port 22"
  }]
}

variable "AMI" {
  default     = "ami-0e4d9ed95865f3b40"
  description = "AMI"
  type        = string
}

variable "key_pair" {
  description = "Key pair to use for the EC2 Instances and bastion"
}

variable "bucket_name" {
  #default = "terraform-state"
  type = string
  description = "S3 bucket for terraform state file"
}