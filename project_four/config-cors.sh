#!/bin/bash


rest_api_id=jnsd0qxgva
stage=dev
ORIGIN="http://localhost:5173"
LS="--endpoint-url http://localhost:4566"

resource_coffee_one=ogseiqq6nx
resource_coffee_id=7jumq2trvk


### Add CORS to /coffee 
# OPTIONS method
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method OPTIONS --authorization-type NONE $LS

# OPTIONS → MOCK integration
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method OPTIONS --type MOCK --request-templates '{ "application/json": "{\"statusCode\": 200}" }' $LS

# Method response
aws apigateway put-method-response --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method OPTIONS --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true,
                          "method.response.header.Access-Control-Allow-Methods": true,
                          "method.response.header.Access-Control-Allow-Headers": true}' $LS
						  
# Integration response (CORS headers)
aws apigateway put-integration-response --rest-api-id $rest_api_id --resource-id $resource_coffee_one --http-method OPTIONS --status-code 200 \
  --response-parameters "{\"method.response.header.Access-Control-Allow-Origin\":\"'$ORIGIN'\", 
                          \"method.response.header.Access-Control-Allow-Methods\":\"GET,POST,PUT,DELETE,OPTIONS\", 
                          \"method.response.header.Access-Control-Allow-Headers\":\"Content-Type\"}" $LS

						  
### Add CORS to /coffee/{id}
aws apigateway put-method --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method OPTIONS --authorization-type NONE $LS

# OPTIONS → MOCK integration
aws apigateway put-integration --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method OPTIONS --type MOCK --request-templates '{ "application/json": "{\"statusCode\": 200}" }' $LS

# Method response
aws apigateway put-method-response --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method OPTIONS --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true,
                          "method.response.header.Access-Control-Allow-Methods": true,
                          "method.response.header.Access-Control-Allow-Headers": true}' $LS
						  
# Integration response (CORS headers)
aws apigateway put-integration-response --rest-api-id $rest_api_id --resource-id $resource_coffee_id --http-method OPTIONS --status-code 200 \
  --response-parameters "{\"method.response.header.Access-Control-Allow-Origin\":\"'$ORIGIN'\", 
                          \"method.response.header.Access-Control-Allow-Methods\":\"GET,POST,PUT,DELETE,OPTIONS\", 
                          \"method.response.header.Access-Control-Allow-Headers\":\"Content-Type\"}" $LS


### Add global CORS for 4XX & 5XX

aws apigateway put-gateway-response --rest-api-id $rest_api_id --response-type DEFAULT_4XX \
  --response-parameters "{\"gatewayresponse.header.Access-Control-Allow-Origin\":\"'$ORIGIN'\", 
                          \"gatewayresponse.header.Access-Control-Allow-Headers\":\"*\", 
                          \"gatewayresponse.header.Access-Control-Allow-Methods\":\"*\"}" $LS
						  
aws apigateway put-gateway-response --rest-api-id $rest_api_id --response-type DEFAULT_5XX \
  --response-parameters "{\"gatewayresponse.header.Access-Control-Allow-Origin\":\"'$ORIGIN'\", 
                          \"gatewayresponse.header.Access-Control-Allow-Headers\":\"*\", 
                          \"gatewayresponse.header.Access-Control-Allow-Methods\":\"*\"}" $LS

### Deploy again

aws apigateway create-deployment --rest-api-id $rest_api_id  --stage-name dev $LS


