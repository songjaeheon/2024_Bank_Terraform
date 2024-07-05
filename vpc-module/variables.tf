variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  # Seoul region
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tag_prefix" {
  description = "Prefix for tags and names"
  type        = string
  default     = "2024_bank"
}
