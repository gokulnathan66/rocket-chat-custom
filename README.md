# Rocket.Chat Custom Docker Deployment

A comprehensive Docker-based deployment solution for Rocket.Chat with Google Cloud Run support and MongoDB Atlas integration.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🚀 Overview

This repository provides a containerized Rocket.Chat deployment solution optimized for:
- **Google Cloud Run** deployment
- **MongoDB Atlas** integration
- **Docker** containerization
- **Production-ready** configuration

## 📦 Prerequisites

Before getting started, ensure you have the following installed and configured:

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (for Cloud Run deployment)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) account with admin access
- [Rocket.Chat](https://rocket.chat/) tarball (`rocket.chat.tgz`)

## 📁 Project Structure

```
rocket.chat/
├── Dockerfile              # Docker image configuration
├── start.sh               # Application startup script
├── env.example            # Environment variables template
├── env.yaml              # YAML environment configuration
├── .gitignore            # Git ignore patterns
├── README.md             # This documentation
└── run.md               # Deployment commands reference
```

### File Descriptions

- **`Dockerfile`**: Multi-stage Docker build configuration for Rocket.Chat
- **`start.sh`**: Startup script with environment variable handling
- **`env.example`**: Template for environment variables configuration
- **`env.yaml`**: YAML format environment configuration for Cloud Run
- **`.gitignore`**: Excludes sensitive files and build artifacts

## ⚡ Quick Start

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd rocket.chat
```

### 2. Configure Environment
```bash
# Copy the environment template
cp env.example .env

# Edit with your MongoDB credentials
nano .env
```

### 3. Build Docker Image
```bash
# Build for Linux AMD64 platform
docker build --platform linux/amd64 -t rocketchat-custom .
```

### 4. Run Locally
```bash
# Run with environment file
docker run -it --rm --env-file .env -p 8080:8080 --name rocketchat-local rocketchat-custom
```

## ⚙️ Configuration

### Environment Variables

#### Required Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `MONGO_URL` | MongoDB connection string | `mongodb+srv://username:password@cluster.mongodb.net/` |
| `MONGO_OPLOG_URL` | MongoDB Oplog URL | `mongodb+srv://username:password@cluster.mongodb.net/` |
| `ROOT_URL` | Application root URL | `https://your-domain.com` |
| `DEPLOY_METHOD` | Deployment method | `docker` |

#### Optional Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Application port |

### Configuration Files

#### `.env` (Local Development)
```bash
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/
MONGO_OPLOG_URL=mongodb+srv://username:password@cluster.mongodb.net/
ROOT_URL=http://localhost:8080
DEPLOY_METHOD=docker
```

#### `env.yaml` (Cloud Run)
```yaml
MONGO_URL: "mongodb+srv://username:password@cluster.mongodb.net/"
MONGO_OPLOG_URL: "mongodb+srv://username:password@cluster.mongodb.net/"
ROOT_URL: "https://your-domain.com"
DEPLOY_METHOD: "docker"
```

> **⚠️ Important**: Do not include the database name in the MongoDB URL as it will cause runtime errors.

## 🚀 Deployment

### Local Development

#### Build Image
```bash
# Build for local testing
docker build --platform linux/amd64 -t rocketchat-custom .
```

#### Run Container
```bash
# Run with environment file
docker run -it --rm --env-file .env -p 8080:8080 --name rocketchat-local rocketchat-custom

# Access application at: http://localhost:8080
```

### Google Cloud Run Deployment

#### Prerequisites
1. Authenticate with Google Cloud:
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

2. Configure Docker for Artifact Registry:
```bash
gcloud auth configure-docker us-docker.pkg.dev
```

3. Tag and push image:
```bash
# Tag image for Artifact Registry
docker tag rocketchat-custom us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest

# Push to registry
docker push us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest
```

#### Deploy to Cloud Run

##### Option 1: Using Environment Variables
```bash
gcloud run deploy rocketchat-custom \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=1Gi \
  --cpu=1 \
  --allow-unauthenticated \
  --port=3000 \
  --set-env-vars="MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/,MONGO_OPLOG_URL=mongodb+srv://username:password@cluster.mongodb.net/,ROOT_URL=https://your-domain.com,DEPLOY_METHOD=docker"
```

##### Option 2: Using YAML Configuration
```bash
gcloud run deploy rocketchat-custom \
  --image=us-docker.pkg.dev/YOUR_PROJECT_ID/rocketchat-repo/rocketchat-custom:latest \
  --platform=managed \
  --region=us-central1 \
  --memory=1Gi \
  --cpu=1 \
  --allow-unauthenticated \
  --port=3000 \
  --env-vars-file=env.yaml
```

#### Production Deployment
```bash
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
  --env-vars-file=env.yaml
```

## 🔒 Security Considerations

### MongoDB Configuration
- **Admin Access**: Ensure your MongoDB user has admin access to the database
- **Global Access**: Configure your MongoDB cluster for global access or set up a private endpoint
- **Strong Passwords**: Use strong, unique passwords for database authentication
- **IP Whitelisting**: Consider restricting access to specific IP ranges

### Cloud Run Security
- **Private Endpoints**: For production, consider using private endpoints with Cloud Run
- **Environment Variables**: Use Google Secret Manager for sensitive configuration
- **Network Security**: Implement VPC connector for enhanced network security

### Best Practices
- Regularly update Rocket.Chat and dependencies
- Monitor logs for suspicious activities
- Implement proper backup strategies
- Use HTTPS for all external communications

## 🐛 Troubleshooting

### Common Issues

#### Port Configuration
- **Issue**: Port misconfiguration in Cloud Run
- **Solution**: Cloud Run automatically resolves port issues, but ensure your application listens on the correct port

#### MongoDB Connection
- **Issue**: Connection timeout or authentication failures
- **Solution**: 
  - Verify MongoDB credentials
  - Check network connectivity
  - Ensure database user has proper permissions

#### Build Issues
- **Issue**: Docker build failures
- **Solution**: Ensure `rocket.chat.tgz` is present in the build context

### Debugging Commands

```bash
# Check container logs
docker logs rocketchat-local

# Access container shell
docker exec -it rocketchat-local bash

# Test MongoDB connection
mongosh "mongodb+srv://username:password@cluster.mongodb.net/"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in this repository
- Check [Rocket.Chat Documentation](https://docs.rocket.chat/)
- Visit [Google Cloud Run Documentation](https://cloud.google.com/run/docs)

---

**Happy Deploying! 🚀** 