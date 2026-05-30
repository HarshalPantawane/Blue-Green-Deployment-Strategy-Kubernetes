#!/bin/bash
# scripts/build.sh
set -e

IMAGE_TAG=$1

if [ -z "$IMAGE_TAG" ]; then
  echo "Usage: $0 <image-tag>"
  exit 1
fi

echo "Building Backend Docker image..."
cd ../app/backend
docker build -t food-delivery-backend:${IMAGE_TAG} -f ../Dockerfile .

echo "Building Frontend Docker image..."
cd ../frontend
docker build -t food-delivery-frontend:${IMAGE_TAG} .

echo "Build successful for both Frontend and Backend."
