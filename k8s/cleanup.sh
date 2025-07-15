#!/bin/bash

echo "🧹 Cleaning up eShop Kubernetes deployment..."

# Delete ingress first
echo "🚪 Removing ingress..."
kubectl delete -f ingress.yaml --ignore-not-found=true

# Delete applications
echo "🌐 Removing applications..."
kubectl delete -f nginx-gateway.yaml --ignore-not-found=true
kubectl delete -f webapp.yaml --ignore-not-found=true
kubectl delete -f webhook-client.yaml --ignore-not-found=true

# Delete API services
echo "🔧 Removing API services..."
kubectl delete -f identity-api.yaml --ignore-not-found=true
kubectl delete -f catalog-api.yaml --ignore-not-found=true
kubectl delete -f basket-api.yaml --ignore-not-found=true
kubectl delete -f ordering-api.yaml --ignore-not-found=true
kubectl delete -f webhooks-api.yaml --ignore-not-found=true
kubectl delete -f mobile-bff.yaml --ignore-not-found=true

# Delete infrastructure
echo "🗄️  Removing infrastructure..."
kubectl delete -f postgres.yaml --ignore-not-found=true
kubectl delete -f redis.yaml --ignore-not-found=true
kubectl delete -f rabbitmq.yaml --ignore-not-found=true

# Delete namespace (this will clean up everything)
echo "📁 Removing namespace..."
kubectl delete namespace eshop --ignore-not-found=true

echo "✅ Cleanup completed!"
