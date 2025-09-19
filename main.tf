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

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function
resource "aws_lambda_function" "example" {
  filename         = data.archive_file.example.output_path
  function_name    = "example_lambda_function"
  role             = aws_iam_role.example.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.example.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "example"
  }
}

action "aws_lambda_invoke" "example" {
  config {
    function_name = aws_lambda_function.example.function_name
    payload = jsonencode({
      length = 10
      width = 5
    })
  }
}

resource "terraform_data" "example" {
  input = "trigger-lambda"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_lambda_invoke.example]
    }
  }
}