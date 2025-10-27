#!/bin/bash

set -e  # Exit on any error

echo "🔥 Starting Kinesis Trading System Destruction..."
echo "⚠️  This will destroy ALL resources. Press Ctrl+C to cancel."
sleep 5

# Empty S3 buckets before destruction
echo "🗑️  Emptying S3 buckets..."
aws s3 rm s3://kinesis-s3-bucket-101 --recursive --quiet || echo "Data bucket already empty or doesn't exist"
aws s3 rm s3://kinesis-athena-results-101 --recursive --quiet || echo "Athena results bucket already empty or doesn't exist"

# Stage 5: Analytics (Glue, Athena) - Destroy first
echo "📊 Destroying Stage 5: Analytics..."
cd stages/5-analytics
terraform init
terraform destroy -var-file="analytics.tfvars" -auto-approve
cd ../..

# Stage 4: Consumers (Lambda, DynamoDB)
echo "⚡ Destroying Stage 4: Consumers..."
cd stages/4-consumers
terraform init
terraform destroy -var-file="consumers.tfvars" -auto-approve
cd ../..

# Stage 3: Producers (ECS with Docker)
echo "🏭 Destroying Stage 3: Producers..."
cd stages/3-producers
terraform init
terraform destroy -var-file="producers.tfvars" -auto-approve
cd ../..

# Stage 2: Data Streaming (Kinesis, Firehose, S3)
echo "🌊 Destroying Stage 2: Data Streaming..."
cd stages/2-data-streaming
terraform init
terraform destroy -var-file="data-streaming.tfvars" -auto-approve
cd ../..

# Stage 1: Foundation (VPC, Network Firewall) - Destroy last
echo "📡 Destroying Stage 1: Foundation..."
cd stages/1-foundation
terraform init
terraform destroy -var-file="foundation.tfvars" -auto-approve
cd ../..

echo "💥 Destruction Complete!"
echo "🧹 All AWS resources have been removed."