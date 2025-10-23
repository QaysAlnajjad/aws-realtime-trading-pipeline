import json
import boto3
import os
from datetime import datetime
import uuid
import base64

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Get environment variables
DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']
S3_BUCKET = os.environ['S3_BUCKET']

def lambda_handler(event, context):
    table = dynamodb.Table(DYNAMODB_TABLE)
    
    for record in event['Records']:
        # Decode Kinesis data
        kinesis_data = record['kinesis']['data']
        decoded_data = base64.b64decode(kinesis_data).decode('utf-8')
        payload = json.loads(decoded_data)
        
        # Extract stock data
        symbol = payload['symbol']
        price = float(payload['price'])
        timestamp = payload['timestamp']
        
        # Simple trading logic
        if should_buy(price):
            create_position(table, symbol, price, timestamp, 'BUY')
        elif should_sell(symbol, price, table):
            close_position(table, symbol, price, timestamp)
    
    return {'statusCode': 200}

def should_buy(price):
    # Simple buy signal: price drop > 2%
    return price < 100  # Placeholder logic

def should_sell(symbol, current_price, table):
    # Check if we have open position and profit > 5%
    try:
        response = table.get_item(Key={'symbol': symbol})
        if 'Item' in response:
            entry_price = float(response['Item']['entry_price'])
            return (current_price - entry_price) / entry_price > 0.05
    except:
        pass
    return False

def create_position(table, symbol, price, timestamp, action):
    position_id = str(uuid.uuid4())
    table.put_item(Item={
        'symbol': symbol,
        'position_id': position_id,
        'entry_price': price,
        'timestamp': timestamp,
        'action': action
    })

def close_position(table, symbol, price, timestamp):
    # Archive completed trade to S3
    trade_data = {
        'symbol': symbol,
        'exit_price': price,
        'timestamp': timestamp,
        'status': 'CLOSED'
    }
    
    s3_key = f"completed-trades/{symbol}/{timestamp}.json"
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=s3_key,
        Body=json.dumps(trade_data)
    )
    
    # Remove from DynamoDB (simplified - should get actual position_id)
    table.delete_item(Key={'symbol': symbol})
