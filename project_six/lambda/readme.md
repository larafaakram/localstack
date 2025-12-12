
# Commands to create lambda functions

aws iam create-role --role-name api-function-role --assume-role-policy-document file://trust-policy.json

aws lambda create-function --function-name="api-function" --handler app.main.handler --zip-file fileb://my_deployment_package.zip --runtime python3.12 --role arn:aws:iam::000000000000:role/api-function-role

aws lambda update-function-configuration --handler app.main.handler --function-name api-function

aws lambda update-function-code --function-name  api-function --zip-file fileb://my_deployment_package.zip

# Generate event, i recommand to generate this from AWS console, where can avoid indentation and coding error
sam local generate-event apigateway aws-proxy > event.json

aws lambda invoke --function-name api-function --cli-binary-format raw-in-base64-out --payload file://event.json output.json

aws apigateway create-rest-api --apigateway-name apigateway-proxy 

rest_api_id=$(aws apigateway create-rest-api --name apigateway-proxy --query 'id' --output text)

root_id=$(aws apigateway get-resources --rest-api-id $rest_api_id --query 'items[0].id' --output text)

proxy_id=$(aws apigateway create-resource --rest-api-id $rest_api_id --parent-id $root_id --path-part "{proxy+}" --query 'id' --output text)

# Add ANY method
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $proxy_id --http-method ANY --authorization-type NONE

LAMBDA_ARN=$(aws lambda get-function --function-name api-function --query 'Configuration.FunctionArn' --output
 text)

aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $proxy_id --http-method ANY --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations


aws apigateway create-deployment --rest-api-id rphi8qga8q --stage-name dev

aws lambda invoke --function-name api-function --cli-binary-format raw-in-base64-out --payload file://test.json output.json
