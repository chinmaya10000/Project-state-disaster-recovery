terraform {
  backend "s3" {
    bucket = "chinmaya-terraform-state-source"
    key = "infra/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}