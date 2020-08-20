terraform {
  required_version = "0.12.29"
}

provider "aws" {
  region              = "us-east-1"
  version             = "~> 2.70"
  profile             = "pokemon-trainer"
  allowed_account_ids = ["123456789012"]
}
