#!/bin/bash
# scripts/rollback.sh
# Usage: ./rollback.sh <COMPONENT>
set -e

COMPONENT=$1
NAMESPACE="production"
SERVICE_NAME="${COMPONENT}-service"

if [ -z "$COMPONENT" ]; then
  echo "Usage: ./rollback.sh <COMPONENT>"
  exit 1
fi

ACTIVE_ENV=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}')

if [ "$ACTIVE_ENV" == "blue" ]; then
    PREVIOUS_ENV="green"
    PREVIOUS_DEPLOYMENT="${COMPONENT}-green"
else
    PREVIOUS_ENV="blue"
    PREVIOUS_DEPLOYMENT="${COMPONENT}-blue"
fi

echo "Current active ${COMPONENT} environment is ${ACTIVE_ENV}."
echo "Initiating rollback to ${PREVIOUS_ENV}..."

# Scale up previous deployment back to desired state
echo "Scaling up ${PREVIOUS_DEPLOYMENT}..."
kubectl scale deployment/${PREVIOUS_DEPLOYMENT} --replicas=2 -n $NAMESPACE

# Wait for pods to be ready
echo "Waiting for ${PREVIOUS_DEPLOYMENT} to be ready..."
kubectl rollout status deployment/${PREVIOUS_DEPLOYMENT} -n $NAMESPACE --timeout=120s

# Switch traffic back
echo "Switching traffic back to ${PREVIOUS_ENV}..."
kubectl patch service $SERVICE_NAME -n $NAMESPACE -p "{\"spec\":{\"selector\":{\"version\":\"${PREVIOUS_ENV}\"}}}"

echo "Rollback complete. Traffic is now routing to ${PREVIOUS_ENV}."
