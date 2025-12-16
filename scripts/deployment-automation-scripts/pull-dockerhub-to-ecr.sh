#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/config.sh"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="$ECR_REPO_NAME"
IMAGE_TAG="v1"
DOCKERHUB_IMAGE="qaysalnajjad/kinesis-stock-producer:$IMAGE_TAG"


aws ecr describe-repositories --repository-names "$ECR_REPO" --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$ECR_REPO" --region "$AWS_REGION" >/dev/null

ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG"

echo "Logging into Docker Hub (optional)..."
if [[ -n "${DOCKERHUB_USERNAME:-}" && -n "${DOCKERHUB_TOKEN:-}" ]]; then
  echo "$DOCKERHUB_TOKEN" | docker login \
    --username "$DOCKERHUB_USERNAME" \
    --password-stdin
else
  echo "No Docker Hub credentials provided — pulling anonymously."
fi

echo "Pulling image from DockerHub..."
docker pull "$DOCKERHUB_IMAGE"

echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin \
    "$ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com

echo "Tagging image for ECR..."
docker tag "$DOCKERHUB_IMAGE" "$ECR_URI"

echo "Pushing image to ECR..."
docker push "$ECR_URI"

mkdir -p scripts/runtime
echo "Image promoted to ECR: $ECR_URI"
echo "$ECR_URI" > scripts/runtime/producer-ecr-image-uri

