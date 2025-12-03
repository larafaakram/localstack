#!/bin/bash

alias aws="aws --endpoint-url=http://localhost:4566"
DATA="Resources initialized: \n"
echo "Initializing Project Four..."

#### DynamoDB Table Creation and Item Insertion ####
table_name="CoffeeShop"
# Create Table in DynamoDB
aws dynamodb create-table --table-name $table_name --attribute-definitions AttributeName=coffeeId,AttributeType=S --key-schema AttributeName=coffeeId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# Insert Item into DynamoDB Table
aws dynamodb put-item --table-name $table_name --item '{"coffeeId": {"S": "C001"}, "name": {"S": "Espresso"}, "price": {"N": "4.50"}, "available": {"BOOL": true}}'

DATA+="DynamoDB Table Created: $table_name \n"

#### API Gateway GET Method and Lambda Function Creation ####

# Create API Gateway REST API
rest_api_name="CoffeeShop"
description="API for my Lambda function"
rest_api_id=$(aws apigateway create-rest-api --name $rest_api_name --description "$description" --query 'id' --output text)
resource_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text)

DATA+="API Gateway REST API Created: $rest_api_name with ID: $rest_api_id \n"

# Create IAM Role
aws iam create-role --role-name CoffeeShopRole --assume-role-policy-document file:///etc/localstack/init/ready.d/others/trust-policy.json

# Create lambda function for GetItem in CoffeeShop table
aws lambda create-function --function-name getCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip --timeout 90

# Get the ARN of the created Lambda function
getCoffee_ARN=$(aws lambda get-function --function-name getCoffee --query 'Configuration.FunctionArn' --output text)
# For Update lambda function code we can use the below command
#aws lambda update-function-code --function-name  getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip

DATA+="Lambda Function Created: getCoffee with ARN: $getCoffee_ARN \n"

# Create route resources : /coffee and /coffee/id
# Create route resources: /coffee
resource_coffee_one=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $resource_id --path-part "coffee" --query 'id' --output text)

DATA+="API Gateway Resource Created: /coffee with ID: $resource_coffee_one \n"

# Create GET method for /coffee
resource_coffee_get_one=$(aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET --authorization-type NONE --request-parameters "method.request.path.id=true")
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations"
# CHECKPOINT: Verify the method created
get_method=$(aws apigateway get-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method GET)

DATA+="API Gateway Method Created: GET /coffee \n"

# Create route resources: /coffee/id
resource_coffee_id=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $resource_coffee_one --path-part "{id}" --query 'id' --output text)
# Create GET method for /coffee/id
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method GET --authorization-type NONE --request-parameters "method.request.path.id=true"
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:getCoffee/invocations"

DATA+="API Gateway Resource Created: /coffee/{id} with ID: $resource_coffee_id \n"

# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name getCoffee --statement-id apigateway-get-coffee --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"
aws lambda add-permission --function-name getCoffee --statement-id apigateway-get-coffee-id --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/{id}"
# CHECKPOINT: Verify the policy added to the Lambda function
aws lambda get-policy --function-name getCoffee

#### API Gateway POST Method and Lambda Function Creation ####

# Create lambda function postCoffee for PutItem in CoffeeShop table
aws lambda create-function --function-name postCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.postCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/post.zip --timeout 90
# Get the ARN of the created Lambda function
postCoffee_ARN=$(aws lambda get-function --function-name postCoffee --query 'Configuration.FunctionArn' --output text)
# For Update lambda function code we can use the below command
#aws lambda update-function-code --function-name  postCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/post.zip

DATA+="Lambda Function Created: postCoffee with ARN: $postCoffee_ARN \n"  

# Create route resource: /coffee for POST method
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method POST --authorization-type NONE --request-parameters "method.request.path.id=true"
# Add integration for POST method
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:postCoffee/invocations"
# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name postCoffee --statement-id apigateway-post-coffee --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"

DATA+="API Gateway Method Created: POST /coffee \n"

#### API Gateway PUT Method and Integration with Lambda function updateCoffee ####

# Update lambda function updateCoffee for UpdateItem in CoffeeShop table
aws lambda create-function --function-name updateCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.updateCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/update.zip --timeout 90
updateCoffee_ARN=$(aws lambda get-function --function-name updateCoffee --query 'Configuration.FunctionArn' --output text)

DATA+="Lambda Function Created: updateCoffee with ARN: $updateCoffee_ARN \n"

aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method PUT --authorization-type NONE --request-parameters "method.request.path.id=true"
# Add integration for PUT method
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method PUT --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:updateCoffee/invocations"
# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name updateCoffee --statement-id apigateway-put-coffee --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"

DATA+="API Gateway Method Created: PUT /coffee/{id} \n"

#### API Gateway Delete Method Integration with Lambda Function ####

# Update lambda function updateCoffee for UpdateItem in CoffeeShop table
aws lambda create-function --function-name deleteCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler index.deleteCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/delete.zip --timeout 90
deleteCoffee_ARN=$(aws lambda get-function --function-name updateCoffee --query 'Configuration.FunctionArn' --output text)

DATA+="Lambda Function Created: deleteCoffee with ARN: $deleteCoffee_ARN \n"

aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method DELETE --authorization-type NONE --request-parameters "method.request.path.id=true"
# Add integration for PUT method
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method DELETE --type AWS_PROXY --integration-http-method DELETE --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:deleteCoffee/invocations"
# Add permission for API Gateway to invoke the Lambda function
aws lambda add-permission --function-name deleteCoffee --statement-id apigateway-delete-coffee --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:us-east-1:*:$rest_api_id/*/*/coffee/*"

DATA+="API Gateway Method Created: DELETE /coffee/{id} \n"

#### Deploy the API: ####

# Note: we must create a deployment every time we make changes to the API (e.g., adding resources or methods)
aws apigateway create-deployment --rest-api-id $rest_api_id --stage-name dev

echo -e "$DATA"

# Add a layer for Lambda functions
aws lambda publish-layer-version --layer-name DynamodbLayer --zip-file fileb:///etc/localstack/init/ready.d/others/layer.zip --compatible-runtimes nodejs22.x

# Update Lambda functions to use the layer
layer_arn=$(aws lambda get-layer-version --layer-name DynamodbLayer --version-number 1 --query 'LayerVersionArn' --output text)
aws lambda update-function-configuration --function-name getCoffee --layers $layer_arn
aws lambda update-function-configuration --function-name postCoffee --layers $layer_arn
aws lambda update-function-configuration --function-name updateCoffee --layers $layer_arn
aws lambda update-function-configuration --function-name deleteCoffee --layers $layer_arn


#aws lambda update-function-code --function-name  getCoffee --zip-file fileb:///etc/localstack/init/ready.d/others/get.zip

## Testing the API Endpoints using curl commands

# Add Item using POST method
# curl -X POST http://$rest_api_id.execute-api.localhost.localstack.cloud:4566/dev/coffee/ -H "Content-Type: application/json" -d '{"coffeeId": "C003","name": "American","price": 7.50,"available": true}'

# Get Item using GET method
#curl -X GET http://$rest_api_id.execute-api.localhost.localstack.cloud:4566/dev/coffee/C002
#curl -X GET http://$rest_api_id.execute-api.localhost.localstack.cloud:4566/dev/coffee/

# Update Item using PUT method 
# curl -X PUT http://$rest_api_id.execute-api.localhost.localstack.cloud:4566/dev/coffee/C003 -H "Content-Type: application/json" -d '{"name": "Latte","price": 4.90,"available": false}'

# DELETE Item using DELETE method
# curl -X DELETE http://$rest_api_id.execute-api.localhost.localstack.cloud:4566/dev/coffee/C003



# others command

# Delete Method from resource in API Gateway
# aws apigateway delete-method --http-method PUT --resource-id $resource_id --rest-api-id $rest_api_id