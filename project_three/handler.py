import boto3
import json

# Configure the SQS client to connect to LocalStack
sqs = boto3.client('sqs', endpoint_url='http://sqs.us-east-1.localhost.localstack.cloud:4566')

# Configure the DynamoDB client to connect to LocalStack
dynamodb = boto3.resource('dynamodb', endpoint_url='http://host.docker.internal:4566')

# Replace with your LocalStack SQS queue URL
QUEUE_URL = 'http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/order-queue'

# Replace with your DynamoDB table name
TABLE_NAME = 'Orders'

# Get the DynamoDB table resource
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print("Lambda handler invoked.")
    try:
        # Receive messages from the SQS queue
        print(f"Attempting to receive messages from SQS queue: {QUEUE_URL}")
        response = sqs.receive_message(
            QueueUrl=QUEUE_URL,
            MaxNumberOfMessages=10,  # Adjust as needed
            WaitTimeSeconds=5        # Long polling
        )
        print(f"Response from SQS: {response}")

        # Check if messages are available
        if 'Messages' in response:
            print(f"Number of messages received: {len(response['Messages'])}")
            for message in response['Messages']:
                # Process each message
                print(f"Processing message: {message}")
                print(f"Message Body: {message['Body']}")

                # Parse the message body (JSON string)
                message_body = json.loads(message['Body'])
                print(f"Parsed message body: {message_body}")

                # Insert the message into the DynamoDB table
                try:
                    print(f"Inserting message into DynamoDB: {message_body['orderId']}")
                    table.put_item(
                        Item={
                            'orderId': str(message_body['orderId']),  # Use the parsed orderId
                            'item': message_body['item']        # Use the parsed item
                        }
                    )
                    print(f"Successfully inserted message into DynamoDB: {message_body['orderId']}")
                except Exception as db_error:
                    print(f"Error inserting message into DynamoDB: {db_error}")

                # Delete the message after processing
                try:
                    print(f"Deleting message from SQS: {message['MessageId']}")
                    sqs.delete_message(
                        QueueUrl=QUEUE_URL,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                    print(f"Successfully deleted message: {message['MessageId']}")
                except Exception as delete_error:
                    print(f"Error deleting message from SQS: {delete_error}")
        else:
            print("No messages available in the queue.")

        return {
            'statusCode': 200,
            'body': 'SQS messages processed and stored in DynamoDB successfully!',
        }

    except Exception as e:
        print(f"Error processing SQS messages: {e}")
        return {
            'statusCode': 500,
            'body': 'Error processing SQS messages.'
        }
    