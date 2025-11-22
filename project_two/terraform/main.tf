
resource "aws_s3_bucket" "bucket" {
  bucket = "terrabucket"
}

resource "aws_lambda_function" "lambda" {
  function_name = "script"
  handler       = "script.script"
  runtime       = "python2.12"
  role          = aws_iam_role.lambda_role.arn
  filename      = "script.zip"
}
resource "aws_dynamodb_table" "dynamodbtable" {
  name         = "terratable"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"
  range_key = "filename"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "filename"
    type = "S"
  }
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.test]
  
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "script"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role_name"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "*"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  
}

resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = "lambda_iam_policy_name"
  role = aws_iam_role.lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Sid": "Stmt1687200984534",
    "Action": "*",
    "Effect": "Allow",
    "Resource": "*"
    }
  ]
}
EOF
}