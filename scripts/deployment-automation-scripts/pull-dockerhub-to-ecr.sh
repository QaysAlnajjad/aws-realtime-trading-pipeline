#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/config.sh"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DOCKERHUB_IMAGE="qays317/trading-producer:latest"
ECR_REPO="$ECR_REPO_NAME"

ECR_URI="${ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPO}:latest"

echo "Logging into DockerHub..."
docker login

echo "Pulling image from DockerHub..."
docker pull ${DOCKERHUB_IMAGE}

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin \
    ${ACCOUNT_ID}.dkr.ecr.$AWS_REGION.amazonaws.com

echo "Tagging image for ECR..."
docker tag ${DOCKERHUB_IMAGE} ${ECR_URI}

echo "Pushing image to ECR..."
docker push ${ECR_URI}

mkdir -p scripts/runtime
echo "Image promoted to ECR: ${ECR_URI}"
echo "${ECR_URI}" > scripts/runtime/producer-ecr-image-uri
