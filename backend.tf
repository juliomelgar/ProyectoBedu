terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bedu-arquitectura-cesarm"
        key = "prod/s3/terraform-tfstate"
        region = "us-east-1"

        dynamodb_table = "bedu-locks-cesarm"
        encrypt = true
    }
}