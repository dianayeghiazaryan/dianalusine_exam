# We Defined the AWS provider and region
provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">=1.5.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.8.0"
    }
  }

  backend "s3" {
    bucket = "final-exam-dianalusine"
    key    = "paris/dev/dianalusine/terraform.tfstate"
    region = "eu-west-3"
  }
}
