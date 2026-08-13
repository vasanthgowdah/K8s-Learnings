#!/bin/bash
set -e

DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
IMAGE_NAME="django-app"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "=== Django EKS Deployment Script (Docker Hub) ==="

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "Error: DOCKERHUB_USERNAME environment variable is required"
    echo "Usage: DOCKERHUB_USERNAME=yourusername ./deploy.sh"
    exit 1
fi

IMAGE_FULL="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

# Step 1: Login to Docker Hub
echo "Logging into Docker Hub..."
docker login

# Step 2: Build and push Docker image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Tagging image..."
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_FULL}

echo "Pushing image to Docker Hub..."
docker push ${IMAGE_FULL}

# Step 3: Update deployment manifest with Docker Hub image
echo "Updating Kubernetes manifests..."
sed -i.bak "s|YOUR_DOCKERHUB_USERNAME/django-app|${DOCKERHUB_USERNAME}/${IMAGE_NAME}|g" k8s/deployment.yaml
rm -f k8s/deployment.yaml.bak

# Step 4: Create Docker Hub secret (if not exists)
echo "Creating Docker Hub pull secret..."
echo "Run this command manually if the secret doesn't exist:"
echo "  kubectl create secret docker-registry dockerhub-secret \\"
echo "    --docker-server=https://index.docker.io/v1/ \\"
echo "    --docker-username=${DOCKERHUB_USERNAME} \\"
echo "    --docker-password=YOUR_PASSWORD \\"
echo "    --docker-email=YOUR_EMAIL \\"
echo "    -n django-app"

# Step 5: Apply Kubernetes manifests
echo "Deploying to EKS..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml

# Step 6: Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/django-deployment -n django-app

echo "=== Deployment Complete ==="
echo "Image: ${IMAGE_FULL}"
echo ""
echo "To get the ingress URL, run:"
echo "  kubectl get ingress django-ingress -n django-app"
