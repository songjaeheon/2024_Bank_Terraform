provider "aws" {
    # Seoul
    region = "ap-northeast-2"
}

module "vpc" {
    source = "./vpc-module"
}
