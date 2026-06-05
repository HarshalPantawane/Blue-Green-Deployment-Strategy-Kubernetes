# Blue-Green Deployment strategy using Kubernetes

## Overview
This project implements a fully automated, production-grade Blue-Green deployment strategy for a food delivery system, It feature Infrastructure as code (Terraform) 
to provision AWS resources, container orchastration using Kubernetes (AWS EKS), and a robust CI/CD pipeline powered by Jenkins to ensure zero-downtime deployments and safe rollbacks.

## Feature
- **Zero-Downtime Deployments**: Utilizes a Blue-Green strategy to deploy new version without impacting active ausers.
- **Automated CI/CD Pipeline**: jenkins pipeline handles code checkout, SonarQube quality analysis, Docker image builder, ECR push and deployment scripting.
- **Infrastructure as code**: Terraform scripting fully manage the AWS environment, including VPC, EKS cluster, IAM roes, and S3 buckets.
- **Microservices Architecture**: Seperate Frontend (React) and Backend (Node.js/Express) services route via NGINX Ingress Controller.
- **Automated Rolllbacks**: Instant service patching back to the previous stable environment if health checks fail.
- **Secure Configuration**: AWS System Manager (SSM) intergration for managing secrets and environment variables.

## Tech Stack
- **Frontend**: React 18, vite, Lucide React
- **Backend**: Node.js, Express, MySQL2, AWS SDK for SSH
- **Infrastructure**: AWS (EKS, VPC, RDS, S3, IAM, SSM)
- **Containerization & Orchestration**: Docker, Kubernetes, NGINX Ingess Controller
- **CI/CD**: Jenkins, SonarQube, Shell Scripting
- **Infrastructure Priovisioning**: Terraform

### Prerequisites
- AWS CLI
- Terraform
- Kubectl
- Docker
- Jenkins server set up and running

### Installation and Setup
1. **AWS Configuration**:
   Using User Credential

2. **Clone The Repository**:
   ```bash
   git clone https://github.com/HarshalPantawane/Blue-Green-Deployment-Strategy-Kubernetes.git
   cd Blue-Green-Deployment-Strategy-Kubernetes
   ```
3. **Provision Infrastructure**:
   Navigate to the terraform directory and deploy the infrastructure.
   ```bash
   cd terraform/
   terraform init
   terraform plan
   terrafrom apply
   ```

4. **Creating Docker Images**:
   ```bash
   ### Build Backend Image:
   docker build -t backend_app_img .
   
   aws ecr get-login-password --region us-east-1 | \
   docker login --username AWS --password-stdin 890871562773.dkr.ecr.us-east-1.amazonaws.com

   docker tag backend_app_img:latest 890871562773.dkr.ecr.us-east-1.amazonaws.com/backend_app_img:latest
   docker push 890871562773.dkr.ecr.us-east-1.amazonaws.com/backend_app_img:latest

   ### Build Frontend Image:
   docker build -t frontend_img .

   docker tag frontend_app_img:latest 890871562773.dkr.ecr.us-east-1.amazonaws.com/frontend_app_img:latest
   docker push 890871562773.dkr.ecr.us-east-1.amazonaws.com/fronnted_app_img:latest
   ```

5. **Configure Kubernetes**:
   ```bash
   aws eks update-kubernetes --region us-east-1 -- name prod-food-delivery-cluster
   ```

6. **Initial Deployment**:
   Apply the initil baseline "Blue" environment kubernetes manifests manually.
   ```bash
   kubectl apply -f k8s/base/
   kubectl apply -f k8s/blue/
   ```

7. **Configure Jenkins CI/CD**:
   - Add the "Jenkinsfile" to your jenkins job.
   - ensure AWS credential and ECR credential are configured within Jenkins.

## usage
The deployment is entirely manage by the automated scripts located in the "scripts/" directory, 
which are triggered by the Jenkins CI/CD pipeline.

- **Deploying a New version**: When code is pushed or a Jenkins job  is triggered, the pipeline builds the New Docker images and deploys them to the inactive environment (e.g., The Green environment).
- **Traffic Switching**: Once the new environment passes its heath checks, the kubernetes Service selector is patched automatically  to route traffic to the newly deployed version.
- **Rollbacks**: If an issue is detected post-deployment, run the "rollback.sh" script to immediately patch the service back to the previous stable environment.
 








   
   
   



