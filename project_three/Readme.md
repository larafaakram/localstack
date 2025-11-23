
This is my third project in the localStack env


Link: https://dzone.com/articles/build-serverless-poc-using-localstack


create a sqs queue:
# aws sqs create-queue --queue-name order-queue

create a dynamodb table:
# aws dynamodb create-table --table-name Orders --attribute-definitions AttributeName=orderId,AttributeType=S --key-schema AttributeName=orderId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5