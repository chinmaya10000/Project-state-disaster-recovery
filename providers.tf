provider "aws" {
  region = "ap-south-1"
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

# tofu {
#   required_version = ">= 1.10.6"
#   required_providers {
#     aws = {
#       source = "opentofu-community/aws"
#       version = ">= 6.9.0"
#     }
#   }
# }