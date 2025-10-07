provider "aws" {
  region = "ap-south-1"
  alias = "south"
}

provider "aws" {
  region = "us-east-1"
  alias = "east"
}

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.9.0"
    }
  }
}