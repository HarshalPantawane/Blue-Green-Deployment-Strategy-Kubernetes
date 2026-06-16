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

# 1. Switch traffic back instantly (pods are warm standbys)
echo "Switching traffic back to ${PREVIOUS_ENV} instantly..."
kubectl patch service $SERVICE_NAME -n $NAMESPACE -p "{\"spec\":{\"selector\":{\"version\":\"${PREVIOUS_ENV}\"}}}"

# 2. Ensure previous deployment is scaled up to 2 replicas (safety check)
echo "Ensuring ${PREVIOUS_DEPLOYMENT} is scaled to 2 replicas..."
kubectl scale deployment/${PREVIOUS_DEPLOYMENT} --replicas=2 -n $NAMESPACE

# 3. Wait for validation (should be immediate if warm standby was active)
kubectl rollout status deployment/${PREVIOUS_DEPLOYMENT} -n $NAMESPACE --timeout=60s

echo "Rollback complete. Traffic is successfully routed to stable ${PREVIOUS_ENV}."
echo "The failing version remains running for active debugging."

