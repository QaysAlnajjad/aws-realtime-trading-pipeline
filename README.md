# AWS Real-Time Trading Data Pipeline

Enterprise-grade real-time trading data pipeline built on AWS using Kinesis, ECS (Fargate), Lambda, DynamoDB, Glue, and Athena.
The project demonstrates event-driven processing, serverless analytics, secure networking, and fully automated infrastructure deployment using Terraform.

---

## Prerequisites

- AWS CLI configured with sufficient permissions

- Terraform v1.5.0 or later

- Docker (for image promotion to ECR)

- Bash environment (Linux / macOS / WSL)

---

## Required AWS services access:

- VPC, EC2, ECS, ECR

- Kinesis Data Streams & Firehose

- Lambda, DynamoDB

- S3, Glue, Athena

- IAM

---

## Architecture Overview

Infrastructure Stages

1. Foundation

    - VPC with private subnets

    - Internet Gateway

    - VPC Interface & Gateway Endpoints (ECR, S3, Logs, etc.)

2. Data Streaming

    - Kinesis Data Stream (real-time ingestion)

    - Kinesis Firehose (batch delivery)

    - S3 data lake bucket (raw streaming data + trading signals)    

3. Producers (Simulated Producer Application)

    - ECS Fargate service

    - Containerized application that simulates real-time trading events

    - Images pulled from Amazon ECR

    - No runtime internet access

4. Consumers

    - Lambda function triggered by Kinesis

    - Processes trades in near real time

    - Stores active positions in DynamoDB

    - Archives completed trades to S3

5. Analytics

    - AWS Glue Data Catalog

    - Glue Crawler for schema discovery

    - Amazon Athena for SQL analytics

    - Dedicated S3 bucket for Athena query results\

--- 

### Project Structure
```
├── modules/           # Reusable Terraform modules
│   ├── analytics
│   ├── consumers
│   ├── data-streaming
│   ├── foundation
│   ├── producers
│   └── s3
├── stages/            # 5-stage deployment pipeline with a bootstrap stage
│   ├── 0-bootstrap
│   ├── foundation
│   ├── data-streaming
│   ├── producers
│   ├── consumers
│   └── analytics
├── utils/             # Helper scripts and tools
├── .github/workflows/ # CI/CD automation
│   ├── deploy.yml
│   └── destroy.yml
└── scripts/
    └── deployment-automation-scripts/
        ├── config.sh
        ├── deploy.sh
        ├── destroy.sh
        └── stacks_config.sh

```

---

## Deployment

### Local Deployment
```bash
# Deploy the entire pipeline
./scripts/deployment-automation-scripts/deploy.sh

# Destroy all resources
./scripts/deployment-automation-scripts/destroy.sh

```

The deployment script:

- Bootstraps Terraform backend (S3 state bucket)

- Deploys stages in the correct order

- Promotes the Docker image from DockerHub to ECR

- Injects the ECR image URI into the ECS producer stage

- Starts the Glue crawler automatically

### CI/CD Deployment

- Test branch: automatic validation

- Main branch: manual deployment via GitHub Actions

Steps:

- GitHub → Actions

- Select Deploy Trading Pipeline

- Click Run workflow

- Choose the target branch





















---

## Data Flow

### Real-Time Processing Path

```bash 
ECS Producer
   ↓
Kinesis Data Stream
   ↓
Lambda Consumer
   ↓
DynamoDB (active positions)
   ↓
S3 completed-trades/
```
- Low latency

- Event-driven

- Fully serverless after ingestion

### Batch Analytics Path

```bash
Kinesis Stream
   ↓
Firehose (buffered batches)
   ↓
S3 raw-data/
   ↓
Glue Crawler
   ↓
Glue Data Catalog
   ↓
Athena SQL Queries
```
- Optimized for cost

- Schema discovered automatically

- SQL-based analytics

## Analytics & Querying

After deployment, the Glue crawler runs automatically to discover schemas.

Verify crawler status
```bash
aws glue get-crawler --name <crawler-name> --query Crawler.State
```
Wait until the state is READY.

## Query with Athena

1. Open Amazon Athena

2. Select the configured workgroup

3. Run queries:
```bash
-- List discovered tables
SHOW TABLES;

-- Analyze raw trading data
SELECT symbol, AVG(price) AS avg_price, COUNT(*) AS trades
FROM raw_data
GROUP BY symbol;
```

## Trading Logic Overview

Producer

- Generates mock real-time trading events

- Sends records to Kinesis

Consumer (Lambda)

- Detects buy/sell signals

- Maintains open positions in DynamoDB

- Writes completed trades to S3

Analytics

- Raw and completed trades are queryable via Athena

- No ETL jobs required


## Security Highlights

- ECS tasks run in private subnets

- No direct internet access at runtime

- AWS services accessed via VPC Endpoints

- S3 buckets:

    -- Public access fully blocked

    -- Versioning configurable

    -- Lifecycle policies defined per stack

- IAM roles follow least privilege

## Monitoring & Observability

- ECS Console – Producer task health

- Kinesis Metrics – Throughput and shard utilization

- Lambda Logs – Consumer execution

- S3 – Raw and processed data

- Athena – Query execution history


## Key Learnings & Design Decisions

- Built a real-time event-driven pipeline using AWS managed services

- Separated infrastructure stages for clean dependency management

- Used Glue Data Catalog as a metadata layer for S3-based analytics

- Removed runtime internet dependency by using ECR + VPC endpoints

- Designed reusable Terraform modules with clear responsibility boundaries

## Final Notes

This project demonstrates:

- Production-grade AWS architecture

- Secure networking

- Clean Terraform module design

- Real-time + batch analytics in one system

It is intentionally structured to reflect how real systems are built, not just how services are connected.

