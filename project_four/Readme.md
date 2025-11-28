
This my project four in the localStack env

link: https://www.udemy.com/course/aws-serverless-course


## create table dynamodb

# aws dynamodb create-table --table-name CoffeeShop --attribute-definitions AttributeName=coffeeId,AttributeType=S --key-schema AttributeName=coffeeId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# aws dynamodb put-item --table-name CoffeeShop --item '{"coffeeId": {"S": "C001"}, "name": {"S": "Espresso"}, "price": {"N": "4.50"}, "available": {"BOOL": true}}'

## Create IAM role
# aws iam create-role --role-name CoffeeShopRole --assume-role-policy-document file://trust-policy.json

## Create lambda function
# aws lambda create-function --function-name getCoffee --role arn:aws:iam::000000000000:role/CoffeeShopRole --runtime nodejs22.x --handler handler.getCoffee --zip-file fileb://get.zip --timeout 90

# Update lambda function code
# aws lambda update-function-code --function-name  getCoffee --zip-file fileb://get.zip


# aws apigateway get-rest-apis