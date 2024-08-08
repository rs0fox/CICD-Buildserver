#!/bin/bash

# Set variables
AWS_REGION="ap-south-1"
ECR_REPO_GAME="your-ecr-repo-for-game"
ECR_REPO_WEBAPP="your-ecr-repo-for-webapp"
GAME_IMAGE_NAME="game-image"
WEBAPP_IMAGE_NAME="webapp-image"
TAG="latest"

# Authenticate Docker to ECR
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
