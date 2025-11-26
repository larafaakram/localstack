#!/bin/bash

echo "Initializing Project Three..."
# Add your initialization commands here
# create a sqs queue:
aws sqs create-queue --queue-name order-queue

# create a dynamodb table:
aws dynamodb create-table --table-name Orders --attribute-definitions AttributeName=orderId,AttributeType=S --key-schema AttributeName=orderId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# create a lambda function
aws lambda create-function --function-name my-lambda-function --role arn:aws:iam::000000000000:role/execution_role --runtime python3.12 --handler handler.lambda_handler --zip-file fileb://function.zip --timeout 90



