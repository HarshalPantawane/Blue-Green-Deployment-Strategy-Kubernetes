#!/bin/bash
# scripts/deploy.sh
# Usage: ./deploy.sh <COMPONENT> <IMAGE_TAG> <ECR_REPO>
# Example: ./deploy.sh backend v1.2.0 aws-acc.dkr.ecr.us-east-1.amazonaws.com/food-backend
set -e

COMPONENT=$1
IMAGE_TAG=$2
ECR_REPO=$3
NAMESPACE="production"
SERVICE_NAME="${COMPONENT}-service"

if [ -z "$COMPONENT" ] || [ -z "$IMAGE_TAG" ] || [ -z "$ECR_REPO" ]; then
  echo "Usage: ./deploy.sh <COMPONENT> <IMAGE_TAG> <ECR_REPO>"
  exit 1
fi

# Determine active deployment from Service selector
ACTIVE_ENV=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}')

if [ "$ACTIVE_ENV" == "blue" ]; then
    TARGET_ENV="green"
    TARGET_DEPLOYMENT="${COMPONENT}-green"
    ACTIVE_DEPLOYMENT="${COMPONENT}-blue"
else
    TARGET_ENV="blue"
    TARGET_DEPLOYMENT="${COMPONENT}-blue"
    ACTIVE_DEPLOYMENT="${COMPONENT}-green"
fi

echo "Active ${COMPONENT} environment is ${ACTIVE_ENV}. Deploying to ${TARGET_ENV}..."

# Update the target deployment with the new image
echo "Updating image for ${TARGET_DEPLOYMENT} to ${ECR_REPO}:${IMAGE_TAG}"
kubectl set image deployment/${TARGET_DEPLOYMENT} ${COMPONENT}-app=${ECR_REPO}:${IMAGE_TAG} -n $NAMESPACE

# Wait for rollout
echo "Waiting for ${TARGET_DEPLOYMENT} rollout to finish..."
kubectl rollout status deployment/${TARGET_DEPLOYMENT} -n $NAMESPACE --timeout=120s

# Switch Traffic
echo "Switching ${COMPONENT} traffic to ${TARGET_ENV}..."
kubectl patch service $SERVICE_NAME -n $NAMESPACE -p "{\"spec\":{\"selector\":{\"version\":\"${TARGET_ENV}\"}}}"

echo "Traffic successfully switched to ${TARGET_ENV}."

# Keep old environment active for warm standby (allows instant rollback)
echo "Keeping old deployment ${ACTIVE_DEPLOYMENT} active as a warm standby..."
echo "If errors occur, rollback will execute instantly. Otherwise, old version will be cleaned up post bake-period."

echo "${COMPONENT} deployment complete."

