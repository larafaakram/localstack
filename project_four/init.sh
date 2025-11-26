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
aws lambda create-function --function-name getCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime Node.js --handler handler.getCoffee --zip-file fileb://get.zip --timeout 90