terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # us-east-1 adds a bit of latency compared to ca-central-1, but is cheaper and has more AZs
  region = "us-east-1"
}
