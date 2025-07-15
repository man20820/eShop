# eShop Kubernetes Deployment

This directory contains the production Kubernetes manifests for deploying the eShop .NET reference application with HTTPS SSL certificates and complete OAuth/OIDC authentication.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                 NGINX Ingress Controller                    │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │ webapp.tkjpedia.com │  │ identity.tkjpedia.com       │   │
│  │ (HTTPS SSL)         │  │ (HTTPS SSL + CORS)          │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Application Services                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   WebApp    │ │ Identity API│ │    Business APIs        │ │
│  │ - Port 8080 │ │ - Port 8080 │ │ - Catalog API (8080)    │ │
│  │ - OIDC      │ │ - JWT Issuer│ │ - Basket API (8080)     │ │
│  │   Client    │ │ - User Auth │ │ - Ordering API (8080)   │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Services                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │ PostgreSQL  │ │    Redis    │ │       RabbitMQ          │ │
│  │ - Identity  │ │ - Sessions  │ │ - Event Bus             │ │
│  │ - Ordering  │ │ - Basket    │ │ - Async Messaging       │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

### Required Tools
- **Kubernetes cluster** (v1.24+)
- **kubectl** configured to access your cluster
- **NGINX Ingress Controller** installed
- **Valid SSL certificates** for your domain

### SSL Certificates
Place your SSL certificates in the `../tls/tkjpedia.com/` (example) directory:
```
tls/tkjpedia.com/
├── cert1.pem      # Certificate
├── chain1.pem     # Certificate chain
├── fullchain1.pem # Full certificate chain
└── privkey1.pem   # Private key
```

## 🚀 Quick Start

### 1. Deploy Everything
```bash
# Run the automated deployment script
./deploy.sh
```

### 2. Access the Application
```bash
# Forward HTTPS port
kubectl port-forward service/ingress-nginx-controller 8443:443 -n ingress-nginx

# Open browser to:
# https://localhost:8443 (with Host: webapp.tkjpedia.com)
```

## 📁 File Structure

### Core Infrastructure
```
├── namespace.yaml                    # eshop namespace
├── postgres.yaml                     # PostgreSQL database
├── redis.yaml                       # Redis cache
├── rabbitmq.yaml                    # RabbitMQ message broker
└── db-init-complete.yaml           # Database initialization job
```

### Application Services
```
├── catalog-api-fixed.yaml           # Product catalog service
├── basket-api-config-fixed.yaml     # Shopping basket service
├── ordering-api-config-fixed.yaml   # Order management service
├── identity-api-config-https-fixed.yaml  # Authentication service
└── webapp-config-https-fixed.yaml   # Web application
```

### Ingress & SSL
```
├── webapp-ingress-ssl-fixed.yaml    # WebApp HTTPS ingress
└── identity-ingress-ssl-fixed.yaml  # Identity HTTPS ingress
```

### Utilities
```
├── deploy.sh                        # Deployment script
├── cleanup.sh                       # Cleanup script
└── README.md                        # This file
```

## 🔧 Manual Deployment Steps

If you prefer to deploy manually or need to troubleshoot:

### 1. Create Namespace and Infrastructure
```bash
kubectl apply -f namespace.yaml
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f rabbitmq.yaml
```

### 2. Initialize Database
```bash
kubectl apply -f db-init-complete.yaml
kubectl wait --for=condition=complete job/db-init -n eshop --timeout=300s
```

### 3. Deploy Application Services
```bash
kubectl apply -f catalog-api-fixed.yaml
kubectl apply -f identity-api-config-https-fixed.yaml
kubectl apply -f basket-api-config-fixed.yaml
kubectl apply -f ordering-api-config-fixed.yaml
kubectl apply -f webapp-config-https-fixed.yaml
```

### 4. Create SSL Secrets
```bash
# Create TLS secrets from your certificates
kubectl create secret tls webapp-tls-secret \
  --cert=../tls/tkjpedia.com/fullchain1.pem \
  --key=../tls/tkjpedia.com/privkey1.pem \
  -n eshop

kubectl create secret tls identity-tls-secret \
  --cert=../tls/tkjpedia.com/fullchain1.pem \
  --key=../tls/tkjpedia.com/privkey1.pem \
  -n eshop
```

### 5. Deploy Ingress
```bash
kubectl apply -f webapp-ingress-ssl-fixed.yaml
kubectl apply -f identity-ingress-ssl-fixed.yaml
```

## 🔐 SSL/HTTPS Configuration

### Certificate Requirements
- **Type**: Valid SSL certificate (not self-signed)
- **Domain**: Wildcard certificate for `*.tkjpedia.com`
- **Format**: PEM format files

### HTTPS Features
- ✅ **SSL Termination**: At ingress level
- ✅ **HTTP Redirect**: Automatic HTTP → HTTPS redirect
- ✅ **HSTS Headers**: Strict-Transport-Security enabled
- ✅ **Buffer Optimization**: Increased NGINX buffers for OAuth callbacks
- ✅ **CORS Support**: Proper cross-domain authentication

## 🔑 Authentication Configuration

### OAuth/OIDC Flow
1. **User Access**: User visits `https://webapp.tkjpedia.com`
2. **Login Redirect**: WebApp redirects to `https://identity.tkjpedia.com`
3. **Authentication**: User enters credentials
4. **Token Exchange**: Identity Server issues JWT tokens
5. **Service Access**: WebApp uses tokens to access APIs

### Default Users
```
Username: alice@alice
Password: Pass123$

Username: bob@bob  
Password: Pass123$
```

### Service Authentication
- **Identity Server**: Issues JWT tokens with HTTPS issuer
- **API Services**: Validate tokens against `https://identity.tkjpedia.com`
- **Token Forwarding**: WebApp forwards user tokens to backend APIs

## 📊 Monitoring & Verification

### Check Deployment Status
```bash
# Check all pods
kubectl get pods -n eshop

# Check services
kubectl get services -n eshop

# Check ingress
kubectl get ingress -n eshop
```

### Verify SSL Certificates
```bash
# Check TLS secrets
kubectl get secrets -n eshop | grep tls

# Test certificate
echo | openssl s_client -servername webapp.tkjpedia.com -connect localhost:8443 2>/dev/null | openssl x509 -noout -dates
```

### Test Authentication
```bash
# Test identity service
curl -k -H "Host: identity.tkjpedia.com" https://localhost:8443/.well-known/openid-configuration

# Test webapp
curl -k -H "Host: webapp.tkjpedia.com" https://localhost:8443/
```

## 🐛 Troubleshooting

### Common Issues

#### 1. 502 Bad Gateway on OAuth Callback
**Cause**: NGINX buffer sizes too small for OAuth tokens
**Solution**: Already fixed in ingress configs with increased buffer sizes

#### 2. Authentication Fails
**Cause**: Token issuer mismatch between services
**Solution**: All services configured to use `https://identity.tkjpedia.com`

#### 3. SSL Certificate Issues
**Cause**: Invalid or missing certificates
**Solution**: Ensure valid certificates in `../tls/tkjpedia.com/`

#### 4. Service Communication Errors
**Cause**: Services can't validate JWT tokens
**Solution**: Check that all APIs use HTTPS identity URL

### Debug Commands
```bash
# Check pod logs
kubectl logs deployment/webapp -n eshop
kubectl logs deployment/identity-api -n eshop
kubectl logs deployment/basket-api -n eshop

# Check ingress controller logs
kubectl logs deployment/ingress-nginx-controller -n ingress-nginx

# Describe problematic resources
kubectl describe pod <pod-name> -n eshop
kubectl describe ingress -n eshop
```

## 🔄 Updates & Maintenance

### Update Application
```bash
# Rebuild and update images
docker build -t webapp:latest ../src/WebApp/
kubectl rollout restart deployment/webapp -n eshop
```

### Update SSL Certificates
```bash
# Delete old secrets
kubectl delete secret webapp-tls-secret identity-tls-secret -n eshop

# Create new secrets with updated certificates
kubectl create secret tls webapp-tls-secret \
  --cert=../tls/tkjpedia.com/fullchain1.pem \
  --key=../tls/tkjpedia.com/privkey1.pem \
  -n eshop

kubectl create secret tls identity-tls-secret \
  --cert=../tls/tkjpedia.com/fullchain1.pem \
  --key=../tls/tkjpedia.com/privkey1.pem \
  -n eshop

# Restart ingress controller
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx
```

### Scale Services
```bash
# Scale webapp
kubectl scale deployment webapp --replicas=3 -n eshop

# Scale APIs
kubectl scale deployment catalog-api --replicas=2 -n eshop
kubectl scale deployment basket-api --replicas=2 -n eshop
```

## 🧹 Cleanup

### Remove Deployment
```bash
# Use cleanup script
./cleanup.sh

# Or manual cleanup
kubectl delete namespace eshop
kubectl delete secret webapp-tls-secret identity-tls-secret -n eshop
```

## 📚 Additional Resources

- [eShop Documentation](../README.md)
- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review pod and ingress logs
3. Verify SSL certificate validity
4. Ensure all prerequisites are met

## 📝 Notes

- This configuration is production-ready with valid SSL certificates
- All services communicate securely with JWT token validation
- NGINX buffers are optimized for OAuth/OIDC callback handling
- Database data persists across pod restarts
- Horizontal scaling is supported for stateless services
