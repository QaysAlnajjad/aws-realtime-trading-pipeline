# Kinesis Trading Data Pipeline

Real-time trading data pipeline using AWS Kinesis, ECS, Lambda, and analytics services.

## Architecture

1. **Foundation** - VPC, Network Firewall, VPC Endpoints
2. **Data Streaming** - Kinesis Data Streams, Firehose, S3
3. **Producers** - ECS tasks generating mock trading data
4. **Consumers** - Lambda processing trades, DynamoDB for positions
5. **Analytics** - Glue Data Catalog, Athena for SQL queries

## Deployment

```bash
# Deploy entire pipeline
./deploy.sh

# Destroy all resources
./destroy.sh
```

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

## Monitoring

- **ECS Console** - Producer task status
- **Kinesis Console** - Stream metrics
- **Lambda Console** - Consumer execution logs
- **S3 Console** - Data files (5-minute batches)
- **Athena Console** - Query trading data