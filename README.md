# AWS Real-Time Trading Data Pipeline

Enterprise-grade real-time trading data pipeline built with AWS Kinesis, ECS, Lambda, and analytics services. Features automated deployment, real-time processing, and comprehensive monitoring.

## Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** v1.5.0 or later
- **IAM Permissions** for Kinesis, ECS, Lambda, S3, DynamoDB, Glue, Athena
- **Bash** environment (Linux/macOS/WSL)

## Architecture

### Infrastructure Components
1. **Foundation** - VPC, Network Firewall, VPC Endpoints
2. **Data Streaming** - Kinesis Data Streams, Firehose, S3
3. **Producers** - ECS tasks generating mock trading data
4. **Consumers** - Lambda processing trades, DynamoDB for positions
5. **Analytics** - Glue Data Catalog, Athena for SQL queries

### Project Structure
```
├── modules/           # Reusable Terraform modules
├── stages/           # 5-stage deployment pipeline
├── utils/            # Helper scripts and tools
├── .github/workflows/ # CI/CD automation
├── deploy.sh         # One-command deployment
└── destroy.sh        # Clean resource removal
```

## Deployment

### Local Deployment
```bash
# Deploy entire pipeline
./deploy.sh

# Destroy all resources
./destroy.sh
```

### CI/CD Deployment
- **Test Branch**: Automatic deployment on push
- **Main Branch**: Manual deployment via GitHub Actions
  1. Go to Actions → "Deploy Trading Pipeline"
  2. Click "Run workflow" → Select main branch
  3. Click "Run workflow"

## Post-Deployment Setup

### Analytics Ready
The deployment script automatically starts the Glue crawler to discover S3 data schemas.

```bash
# Check crawler status
aws glue get-crawler --name trading-data-crawler | grep State

# Wait for crawler to complete (READY state)
```

### Query Trading Data
Once crawler completes, query your data with Athena:

1. **Switch to trading workgroup** in Athena Console:
   - Settings → Workgroup → Select `trading-analytics`

2. **Run SQL queries:**
```sql
-- Show discovered tables
SHOW TABLES;

-- Analyze trading data
SELECT symbol, AVG(price) as avg_price, COUNT(*) as records
FROM raw_data 
GROUP BY symbol;
```

## Data Flow

### Real-Time Trading System
```
ECS Producer (1 sec) → Kinesis Stream (instant) → Lambda Consumer (instant) → DynamoDB (instant)
                                                                            ↓
                                                                    S3 completed-trades/
```

### Batch Analytics System
```
Kinesis Stream → Firehose (5 min batches) → S3 raw-data/ → Glue Crawler (daily) → Athena Queries
```

**Real-Time:** Trading decisions and position management  
**Batch:** Historical analysis and reporting

### Trading Logic
- **Buy Signal**: Price drops detected by Lambda consumer
- **Sell Signal**: 5% profit threshold reached
- **Position Storage**: DynamoDB for active positions
- **Trade Archive**: S3 for completed trades

## Utilities

### Data Analysis Tool
```bash
# Download and analyze Firehose data
aws s3 cp s3://kinesis-s3-bucket-101/raw-data/2025/01/15/12/file.gz .
gunzip file.gz
python3 utils/parse_trading_data.py file
```

## Monitoring

- **ECS Console** - Producer task status
- **Kinesis Console** - Stream metrics
- **Lambda Console** - Consumer execution logs
- **S3 Console** - Data files (5-minute batches)
- **Athena Console** - Query trading data

## Troubleshooting

**Deployment Issues:**
- Verify AWS credentials: `aws sts get-caller-identity`
- Check Terraform version: `terraform version`

**Data Flow Issues:**
- Monitor Kinesis shard utilization
- Check Lambda error rates and timeouts
- Verify S3 bucket permissions