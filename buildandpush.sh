#!/bin/bash

set -e  # Exit on any error
set -x  # Enable debug mode

# Set variables
DOCKERHUB_REPO_GAME="builddb-game"
DOCKERHUB_REPO_WEBAPP="builddb-webapp"
GAME_IMAGE_NAME="game-image"
WEBAPP_IMAGE_NAME="webapp-image"
TAG="latest"
SECRETS_ID="arn:aws:secretsmanager:ap-south-1:339712721384:secret:dockerhublogin-4vcmMW"  # Correct ARN
ARCHITECTURES="linux/amd64,linux/arm64"

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

# Enable Docker Buildx (if not already enabled)
echo "Enabling Docker Buildx..."
docker buildx create --use || { echo "Failed to create Buildx builder"; exit 1; }

# Build multi-architecture Docker images and push to DockerHub
echo "Building and pushing multi-architecture Docker images..."
docker buildx build --platform $ARCHITECTURES -t $DOCKERHUB_USERNAME/$GAME_IMAGE_NAME:latest ./game --push --progress=plain || { echo "Failed to build and push game-image"; exit 1; }
docker buildx build --platform $ARCHITECTURES -t $DOCKERHUB_USERNAME/$WEBAPP_IMAGE_NAME:latest ./webapp --push --progress=plain || { echo "Failed to build and push webapp-image"; exit 1; }

echo "Docker images have been pushed to DockerHub successfully."
