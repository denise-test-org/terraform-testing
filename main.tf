terraform { 
  cloud { 
    hostname = "app.terraform.io" 
    organization = "team-tf-actions-test-org" 

    workspaces { 
      name = "terraform-testing" 
    } 
  } 

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
