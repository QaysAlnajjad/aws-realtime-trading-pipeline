# Utilities

Helper scripts for testing and validating the Kinesis trading pipeline.

## parse_trading_data.py

Analyzes downloaded Firehose data files from S3.

**Usage:**
```bash
# Download a data file from S3
aws s3 cp s3://kinesis-s3-bucket-101/raw-data/2025/10/22/12/file.gz .
gunzip file.gz

# Analyze the data
python3 utils/parse_trading_data.py file
```

**Output:**
- Total record count
- Statistics per stock symbol (avg price, volume, etc.)
- Price ranges and trading activity