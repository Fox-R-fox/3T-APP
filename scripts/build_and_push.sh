#!/bin/bash

# Variables
FRONTEND_IMAGE="foxe03/frontend:latest"
BACKEND_IMAGE="foxe03/backend:latest"

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

# Build the Docker images
echo "Building Docker images..."
docker build -t $FRONTEND_IMAGE ./docker/frontend
docker build -t $BACKEND_IMAGE ./docker/backend

# Push the Docker images to Docker Hub
echo "Pushing Docker images to Docker Hub..."
docker push $FRONTEND_IMAGE
docker push $BACKEND_IMAGE

echo "Docker images built and pushed successfully!"
