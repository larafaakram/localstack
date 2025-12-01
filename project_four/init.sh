#!/bin/bash

alias aws="aws --endpoint-url=http://localhost:4566"

echo "Initializing Project Four..."

# Create Table in DynamoDB
aws dynamodb create-table --table-name CoffeeShop --attribute-definitions AttributeName=coffeeId,AttributeType=S --key-schema AttributeName=coffeeId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# Insert Item into DynamoDB Table
aws dynamodb put-item --table-name CoffeeShop --item '{"coffeeId": {"S": "C001"}, "name": {"S": "Espresso"}, "price": {"N": "4.50"}, "available": {"BOOL": true}}'

# Create IAM Role
aws iam create-role --role-name CoffeeShopRole --assume-role-policy-document file:///etc/localstack/init/ready.d/others/trust-policy.json

# Create lambda function for GetItem in CoffeeShop table
aws lambda create-function --function-name getCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip --timeout 90

# Get the ARN of the created Lambda function
LAMBDA_ARN=$(aws lambda get-function --function-name getCoffee --query 'Configuration.FunctionArn' --output text)
# For Update lambda function code we can use the below command
#aws lambda update-function-code --function-name  getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip

# Create API Gateway REST API
rest_api_name="CoffeeShop"
description="API for my Lambda function"
rest_api_id=$(aws apigateway create-rest-api --name $rest_api_name --description "$description" --query 'id' --output text)
resource_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text)

# Create route resources : /coffee and /coffee/id
# Create route resources: /coffee
resource_coffee_one=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $resource_id --path-part "coffee" --query 'id' --output text)
resource_coffee_get_one=$(aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET --authorization-type NONE --request-parameters "method.request.path.id=true")


aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations"
# CHECKPOINT: Verify the method created
aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET


# Create route resources: /coffee/id
resource_coffee_two=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $resource_coffee_one --path-part "{id}" --query 'id' --output text)
resource_coffee_get_two=$(aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_two --http-method GET --authorization-type NONE --request-parameters "method.request.path.id=true")

aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_two --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations"

# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name getCoffee --statement-id apigateway-test-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"
aws lambda add-permission --function-name getCoffee --statement-id apigateway-test-invoke-id --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/{id}"
# CHECKPOINT: Verify the policy added to the Lambda function
aws lambda get-policy --function-name getCoffee

# Create lambda function postCoffee for PutItem in CoffeeShop table
aws lambda create-function --function-name postCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.postCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/post.zip --timeout 90

# Get the ARN of the created Lambda function
LAMBDA_ARN=$(aws lambda get-function --function-name postCoffee --query 'Configuration.FunctionArn' --output text)
# For Update lambda function code we can use the below command
#aws lambda update-function-code --function-name  postCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/post.zip

# Create route resource: /coffee for POST method
resource_coffee_post_one=$(aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method POST --authorization-type NONE --request-parameters "method.request.path.id=true")
# Add integration for POST method
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:postCoffee/invocations"
# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name postCoffee --statement-id apigateway-post-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"

# Update lambda function updateCoffee for UpdateItem in CoffeeShop table
aws lambda create-function --function-name updateCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.updateCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/update.zip --timeout 90
resource_coffee_put=$(aws apigateway put-method --rest-api-id hnpctuzurp --resource-id k4rcv5hjsx --http-method PUT --authorization-type NONE --request-parameters "method.request.path.id=true") 
# Add integration for PUT method
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_two --http-method PUT --type AWS_PROXY --integration-http-method PUT --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:updateCoffee/invocations"
# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name updateCoffee --statement-id apigateway-put-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"



# Deploy the API:
# Note: we must create a deployment every time we make changes to the API (e.g., adding resources or methods)
aws apigateway create-deployment --rest-api-id $rest_api_id --stage-name dev





###
# Add Item using POST method
curl -X POST http://hnpctuzurp.execute-api.localhost.localstack.cloud:4566/dev/coffee/ -H "Content-Type: application/json" -d '{"coffeeId": "C003","name": "American","price": 7.50,"available": true}'

# Get Item using GET method
curl -X GET http://hnpctuzurp.execute-api.localhost.localstack.cloud:4566/dev/coffee/C002
curl -X GET http://hnpctuzurp.execute-api.localhost.localstack.cloud:4566/dev/coffee/

# Update Item using PUT method
curl -X PUT http://hnpctuzurp.execute-api.localhost.localstack.cloud:4566/dev/coffee/C003 -H "Content-Type: application/json" -d '{"name": "Latte","price": 4.90,"available": false}'
curl -X PUT \
  https://YOUR_API_URL/coffee/123 \
  -H "Content-Type: application/json" \
  -d '{"name": "Latte","price": 4.90,"available": false}' 



# --request-parameters "integration.request.path.coffee=method.request.path.coffee"
# --request-parameters "integration.request.path.coffee.id=method.request.path.coffee.id
# Manually adding the below line as it was getting cut off
#aws apigateway put-integration --rest-api-id 2xch728gbn --resource-id fg9bcig4r4 --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations" --request-parameters "integration.request.path.coffee=method.request.path.coffee"
#aws apigateway put-integration --rest-api-id 2xch728gbn --resource-id kbgopixbxo --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations" --request-parameters "integration.request.path.coffee.id=method.request.path.coffee.id"
# Add permission for API Gateway to invoke the Lambda function
#aws lambda add-permission --function-name getCoffee --statement-id apigateway-test-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/GET/coffee/*"
# Manually adding the below line as it was getting cut off
#aws lambda add-permission --function-name getCoffee --statement-id apigateway-test-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:2xch728gbn/*/GET/coffee/*"




# Delete Method from resource in API Gateway
# aws apigateway delete-method --http-method PUT --resource-id k4rcv5hjsx --rest-api-id hnpctuzurp
