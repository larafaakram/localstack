
This is my third project in the localStack env


Link: https://dzone.com/articles/build-serverless-poc-using-localstack


create a sqs queue:
# aws sqs create-queue --queue-name order-queue

create a dynamodb table:
# aws dynamodb create-table --table-name Orders --attribute-definitions AttributeName=orderId,AttributeType=S --key-schema AttributeName=orderId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

create a lambda function
# aws lambda create-function --function-name my-lambda-function --role arn:aws:iam::000000000000:role/execution_role --runtime python3.12 --handler handler.lambda_handler --zip-file fileb://function.zip --timeout 90

# aws sqs send-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/order-queue --message-body '{"order_id": "123", "item": "Book"}'


# aws sqs receive-message --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/order-queue


# aws lambda invoke --function-name my-lambda-function output.txt

# aws dynamodb scan --table-name Orders 