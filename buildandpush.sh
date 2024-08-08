#!/bin/bash

set -e  # Exit on any error
set -x  # Enable debug mode

# Set variables
AWS_REGION="ap-south-1"
ECR_REPO_GAME="builddb-game"
ECR_REPO_WEBAPP="builddb-webapp"
GAME_IMAGE_NAME="game-image"
WEBAPP_IMAGE_NAME="webapp-image"
TAG="latest"
SECRETS_ID="arn:aws:secretsmanager:ap-south-1:339712721384:secret:dockerhub-G8QpL5"  # Correct ARN

# Retrieve DockerHub credentials from AWS Secrets Manager
echo "Retrieving DockerHub credentials from AWS Secrets Manager..."
DOCKERHUB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRETS_ID --query SecretString --output text)
DOCKERHUB_USERNAME=$(echo $DOCKERHUB_CREDENTIALS | jq -r .username)
DOCKERHUB_PASSWORD=$(echo $DOCKERHUB_CREDENTIALS | jq -r .password)

# Check if credentials are retrieved successfully
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_PASSWORD" ]; then
  echo "Failed to retrieve DockerHub credentials from AWS Secrets Manager."
  exit 1
fi

# Authenticate Docker to DockerHub
echo "Authenticating Docker to DockerHub..."
echo $DOCKERHUB_PASSWORD | docker login --username $DOCKERHUB_USERNAME --password-stdin

# Authenticate Docker to ECR
echo "Authenticating Docker to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com

# Build the Docker images
echo "Building Docker images..."
docker build -t $GAME_IMAGE_NAME:latest ./game
docker build -t $WEBAPP_IMAGE_NAME:latest ./webapp

# Tag the Docker images
echo "Tagging Docker images..."
docker tag $GAME_IMAGE_NAME:latest $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_GAME:$TAG
docker tag $WEBAPP_IMAGE_NAME:latest $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_WEBAPP:$TAG

# Push the Docker images to ECR
echo "Pushing Docker images to ECR..."
docker push $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_GAME:$TAG
docker push $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_WEBAPP:$TAG

echo "Docker images have been pushed to ECR successfully."
