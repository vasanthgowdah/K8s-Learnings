# Django on EKS

A sample Django application configured for deployment on Amazon EKS.

## Project Structure

```
EKS_Python_Django/
├── app/                    # Django application
│   ├── myapp/              # Django project
│   ├── manage.py
│   └── requirements.txt
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
├── Dockerfile
├── deploy.sh
└── README.md
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Docker installed
- kubectl configured for your EKS cluster
- AWS Load Balancer Controller installed on EKS (for ALB Ingress)

## Deployment Steps

### 1. Configure kubectl for EKS

```bash
aws eks update-kubeconfig --name YOUR_CLUSTER_NAME --region YOUR_REGION
```

### 2. Update Secrets (Important!)

Edit `k8s/secret.yaml` and replace placeholder values:
- `DJANGO_SECRET_KEY`: Generate a secure key
- `DB_PASSWORD`: Your database password

### 3. Deploy

```bash
# Make deploy script executable
chmod +x deploy.sh

# Set environment variables
export AWS_REGION=us-west-2
export IMAGE_TAG=v1.0.0

# Run deployment
./deploy.sh
```

### 4. Get Application URL

```bash
kubectl get ingress django-ingress -n django-app
```

## Manual Deployment (without script)

```bash
# Build and push image
docker build -t django-app .
docker tag django-app:latest YOUR_ECR_URL:latest
docker push YOUR_ECR_URL:latest

# Deploy to Kubernetes
kubectl apply -f k8s/
```

## Endpoints

- `/` - Welcome message
- `/health/` - Health check endpoint
- `/admin/` - Django admin

## Configuration

Environment variables are managed via:
- `k8s/configmap.yaml` - Non-sensitive configuration
- `k8s/secret.yaml` - Sensitive data (passwords, keys)

## Scaling

The HPA automatically scales pods between 3-10 replicas based on CPU/memory utilization.

Manual scaling:
```bash
kubectl scale deployment django-deployment -n django-app --replicas=5
```
# K8s-Learnings
