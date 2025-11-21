resource "aws_s3_bucket" "terraform_notes_bucket" {
  bucket = "terraform-notes"
}

resource "aws_dynamodb_table" "terraform_notes_dynamodb_table" {
  name = "terraform-notes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "file_name"

  attribute {
   name = "file_name"
   type = "S"
  }
}


data "aws_iam_policy_document" "mock_lambda_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }  
  }
}

resource "aws_iam_role" "notes_processing_lambda_iam" {
  name = "terraform_notes_processing_lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.mock_lambda_role.json
}


resource "aws_lambda_function" "notes_processing_lambda" {
  function_name = "terraform_notes_processing_lambda"
  role          = aws_iam_role.notes_processing_lambda_iam.arn
  handler       = "terraform_notes_processor_lambda.lambda_handler"
  runtime       = "python3.12"
  filename = "${path.module}/../terraform_notes_processor_lambda.zip"
}
  