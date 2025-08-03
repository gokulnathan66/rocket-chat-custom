# ==============================================
# Rocket.Chat Deployment Commands Reference
# ==============================================
# Quick reference for building and deploying Rocket.Chat

# ==============================================
# Docker Build Commands
# ==============================================

# Build for Linux AMD64 platform (required for Cloud Run)
docker build --platform linux/amd64 -t rocketchat-custom .

# Build with specific tag for versioning
docker build --platform linux/amd64 -t rocketchat-custom:v1.0.0 .

# Build with no-cache for fresh build
docker build --platform linux/amd64 --no-cache -t rocketchat-custom .

# ==============================================
# Local Development Commands
# ==============================================

# Run locally with environment file
docker run -it --rm --env-file .env -p 8080:8080 --name rocketchat-local rocketchat-custom

# Run with specific environment variables
docker run -it --rm \
  -e MONGO_URL="mongodb+srv://user:pass@cluster.mongodb.net/" \
  -e MONGO_OPLOG_URL="mongodb+srv://user:pass@cluster.mongodb.net/" \
  -e ROOT_URL="http://localhost:8080" \
  -e DEPLOY_METHOD="docker" \
  -p 8080:8080 \
  --name rocketchat-local \
  rocketchat-custom

# Run in detached mode
docker run -d --env-file .env -p 8080:8080 --name rocketchat-local rocketchat-custom

# ==============================================
# Google Cloud Setup Commands
# ==============================================

# Authenticate with Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Configure Docker for Artifact Registry
gcloud auth configure-docker us-docker.pkg.dev

# Create Artifact Registry repository (if not exists)
gcloud artifacts repositories create rocketchat-repo \
  --repository-format=docker \
  --location=us-central1

# ==============================================
# Image Tagging and Push Commands
# ==============================================

# Tag image for Artifact Registry
docker tag rocketchat-custom us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest

# Tag with version
docker tag rocketchat-custom us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:v1.0.0

# Push to Artifact Registry
docker push us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest

# ==============================================
# Cloud Run Deployment Commands
# ==============================================

# Deploy with environment variables (Development)
gcloud run deploy rocketchat-custom \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=1Gi \
  --cpu=1 \
  --allow-unauthenticated \
  --port=3000 \
  --set-env-vars="MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/,MONGO_OPLOG_URL=mongodb+srv://username:password@cluster.mongodb.net/,ROOT_URL=https://rocketchat-custom-xxxxxxx-uc.a.run.app,DEPLOY_METHOD=docker"

# Deploy with YAML configuration file
gcloud run deploy rocketchat-custom \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=1Gi \
  --cpu=1 \
  --allow-unauthenticated \
  --port=3000 \
  --env-vars-file=env.yaml

# Production deployment with enhanced configuration
gcloud run deploy rocketchat-production \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=2Gi \
  --cpu=2 \
  --allow-unauthenticated \
  --port=3000 \
  --max-instances=10 \
  --concurrency=100 \
  --timeout=900 \
  --env-vars-file=env.yaml

# ==============================================
# Utility Commands
# ==============================================

# Get service URL
gcloud run services describe rocketchat-custom --region=us-central1 --format="value(status.url)"

# View service logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=rocketchat-custom" --limit=50

# Update service with new environment variables
gcloud run services update rocketchat-custom \
  --region=us-central1 \
  --set-env-vars="NEW_VAR=value"

# Scale service
gcloud run services update rocketchat-custom \
  --region=us-central1 \
  --memory=2Gi \
  --cpu=2

# Delete service
gcloud run services delete rocketchat-custom --region=us-central1

# ==============================================
# Development Workflow
# ==============================================

# Complete build and deploy workflow
# 1. Build image
docker build --platform linux/amd64 -t rocketchat-custom .

# 2. Test locally
docker run -it --rm --env-file .env -p 8080:8080 --name rocketchat-local rocketchat-custom

# 3. Tag for registry
docker tag rocketchat-custom us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest

# 4. Push to registry
docker push us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest

# 5. Deploy to Cloud Run
gcloud run deploy rocketchat-custom \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=1Gi \
  --cpu=1 \
  --allow-unauthenticated \
  --port=3000 \
  --env-vars-file=env.yaml

# ==============================================
# Notes
# ==============================================
# - Replace YOUR_PROJECT_ID with your actual Google Cloud Project ID
# - Update MongoDB credentials in environment files
# - Ensure rocket.chat.tgz is present before building
# - Test locally before deploying to production

