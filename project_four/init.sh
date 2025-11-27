#!/bin/bash

alias aws="aws --endpoint-url=http://localhost:4566"

echo "Initializing Project Four..."

# Create Table in DynamoDB
aws dynamodb create-table --table-name CoffeeShop --attribute-definitions AttributeName=coffeeId,AttributeType=S --key-schema AttributeName=coffeeId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# Insert Item into DynamoDB Table
aws dynamodb put-item --table-name CoffeeShop --item '{"coffeeId": {"S": "C001"}, "name": {"S": "Espresso"}, "price": {"N": "4.50"}, "available": {"BOOL": true}}'

# Create IAM Role
aws iam create-role --role-name CoffeeShopRole --assume-role-policy-document file:///etc/localstack/init/ready.d/others/trust-policy.json

# Create lambda function
aws lambda create-function --function-name getCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler handler.getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip --timeout 90
# For Update lambda function code we can use the below command
#aws lambda update-function-code --function-name  getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip

# Create API Gateway REST API
rest_api_name="CoffeeShop"
description="API for my Lambda function"
rest_api_id=$(aws apigateway create-rest-api --name $rest_api_name --description "$description" --query 'id' --output text)
resource_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text)

# Create route resources
resource_coffee_id=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $resource_id --path-part "coffee" --query 'id' --output text)

aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method GET --authorization-type NONE

#awslocal apigateway put-integration --rest-api-id <YOUR_REST_API_ID> --resource-id <YOUR_RESOURCE_ID> --http-method GET --type HTTP --integration-http-method GET --uri "http://example.com/data" --request-templates '{"application/json": "{\"statusCode\": 200}"}'

#awslocal apigateway create-deployment --rest-api-id <YOUR_REST_API_ID> --stage-name "dev"
