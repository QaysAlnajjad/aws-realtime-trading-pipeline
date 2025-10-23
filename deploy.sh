#!/bin/bash

set -e  # Exit on any error

echo "🚀 Starting Kinesis Trading System Deployment..."

# Stage 1: Foundation (VPC, Network Firewall)
echo "📡 Deploying Stage 1: Foundation..."
cd stages/1-foundation
terraform init
terraform apply -var-file="foundation.tfvars" -auto-approve
cd ../..

# Stage 2: Data Streaming (Kinesis, Firehose, S3)
echo "🌊 Deploying Stage 2: Data Streaming..."
cd stages/2-data-streaming
terraform init
terraform apply -var-file="data-streaming.tfvars" -auto-approve
cd ../..

# Stage 3: Producers (ECS with Docker)
echo "🏭 Deploying Stage 3: Producers..."
cd stages/3-producers
terraform init
terraform apply -var-file="producers.tfvars" -auto-approve
cd ../..

# Stage 4: Consumers (Lambda, DynamoDB)
echo "⚡ Deploying Stage 4: Consumers..."
cd stages/4-consumers
terraform init
terraform apply -var-file="consumers.tfvars" -auto-approve
cd ../..

# Stage 5: Analytics (Glue, Athena)
echo "📊 Deploying Stage 5: Analytics..."
cd stages/5-analytics
terraform init
terraform apply -var-file="analytics.tfvars" -auto-approve
cd ../..

# Start Glue Crawler to discover S3 data
echo "🔍 Starting Glue crawler to discover trading data..."
CRAWLER_NAME=$(cd stages/5-analytics && terraform output -raw glue_crawler_name)
aws glue start-crawler --name "$CRAWLER_NAME"
echo "⏳ Crawler '$CRAWLER_NAME' started. It will run in background to create table schemas."

echo "✅ Deployment Complete!"
echo "🔍 Check AWS Console:"
echo "   - ECS: Producer tasks running"
echo "   - Kinesis: Data stream receiving records"
echo "   - Lambda: Consumer processing records"
echo "   - DynamoDB: Trading positions stored"
echo "   - Glue: Data catalog and crawler ready"
echo "   - Athena: Query workgroup configured"