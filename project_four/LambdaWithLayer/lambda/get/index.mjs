import { docClient, GetCommand, ScanCommand, createResponse } from '/opt/nodejs/utils.mjs';

//import { DynamoDBClient } from "/opt/nodejs/node_modules/@aws-sdk/client-dynamodb";
//import { DynamoDBDocumentClient, GetCommand, ScanCommand } from "/opt/nodejs/node_modules/@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const createResponse = (statusCode, body) => {
    const responseBody = JSON.stringify(body);
    return {
        statusCode,
        headers: { "Content-Type": "application/json" },
        body: responseBody,
    };
};

const tableName = process.env.tableName || "CoffeeShop";

export const getCoffee = async (event) => {
    const { pathParameters } = event;
    const { id } = pathParameters || {};

    try {
        let command;
        if (id) {
            command = new GetCommand({
                TableName: tableName,
                Key: {
                    "coffeeId": id,
                },
            });
        }
        else {
            command = new ScanCommand({
                TableName: tableName,
            });
        }
        const response = await docClient.send(command);
        return createResponse(200, response);
    }
    catch (err) {
        console.error("Error fetching data from DynamoDB:", err);
        return createResponse(500, { error: err.message });
    }

}