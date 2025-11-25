#/bin/bash

echo "Initializing Project Four..."

# Create Table in DynamoDB
aws dynamodb create-table --table-name CoffeeShop --attribute-definitions AttributeName=coffeeId,AttributeType=S --key-schema AttributeName=coffeeId,KeyType=HASH --billing-mode PAY_PER_REQUEST
# Insert Item into DynamoDB Table
aws dynamodb put-item --table-name coffeeShop --item '{"coffeeId": {"S": "C001"}, "name": {"S": "Espresso"}, "price": {"N": "4.50"}, "available": {"BOOL": true}}'
# Create IAM Role
aws iam create-role --role-name CoffeeShopRole --assume-role-policy-document file://trust-policy.json