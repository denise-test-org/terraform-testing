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
    bufo = {
      source = "austinvalle/bufo"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "terraform_data" "test-all-separate" {
  input = "bufo-test"

  lifecycle {
    action_trigger {
      events  = [before_create]
      actions = [action.bufo_print.awesome]
    }
  }
}

action "bufo_print" "awesome" {
  config {
    name = "awesomebufo"
  }
}


