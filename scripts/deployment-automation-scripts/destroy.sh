#!/bin/bash

set -e  # Exit on any error

# Load shared configuration
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/stacks_config.sh" 

if [ -z "$TF_STATE_BUCKET_NAME" ]; then
    echo "❌ ERROR: TF_STATE_BUCKET_NAME variable is required"
    echo "Set TF_STATE_BUCKET_NAME in config.sh"
    exit 1
fi

echo "🔥 Starting AWS ECS WordPress Infrastructure Destruction..."
echo "⚠️  WARNING: This will destroy ALL resources created by deploy.sh"
echo "⚠️  This action is IRREVERSIBLE!"
echo ""

# Skip confirmation when running in CI
if [[ "$CI" == "true" ]]; then
  confirm="yes"
else
  read -p "Are you sure? (yes/no): " confirm
fi

if [[ "$confirm" != "yes" ]]; then
  echo "❌ Destruction cancelled."
  exit 1
fi

echo "🔥 Starting Kinesis Trading System Destruction..."
echo "⚠️  This will destroy ALL resources. Press Ctrl+C to cancel."
sleep 5

# -----------------------------
# Function to destroy a stack
# -----------------------------
destroy_stack() {
  local stack="$1"
  echo "🟦 Destroying: $stack"

  terraform -chdir="environments/$stack" init -reconfigure \
    -backend-config="bucket=$TF_STATE_BUCKET_NAME" \
    -backend-config="key=environments/$stack/terraform.tfstate" \
    -backend-config="region=$TF_STATE_BUCKET_REGION"

  terraform -chdir="environments/$stack" destroy \
    ${STACK_VARS[$stack]} \
    -var aws_region=$AWS_REGION \
    -auto-approve

  echo "✅ Done: $stack"
}

# -----------------------------
# DESTROY ORDER
# -----------------------------

# Empty S3 buckets before destruction
echo "🗑️  Emptying S3 buckets..."
aws s3 rm s3://$DATA_STREAM_S3_BUCKET_NAME --recursive --quiet || echo "Data bucket already empty or doesn't exist"
aws s3 rm s3://$ATHENA_RESULTS_BUCKET_NAME --recursive --quiet || echo "Athena results bucket already empty or doesn't exist"



destroy_stack "analytics"
destroy_stack "consumers"
destroy_stack "producers"
destroy_stack "data-streaming"
destroy_stack "foundation"



echo "💥 Destruction Complete!"
echo "🧹 All AWS resources have been removed."