#!/bin/bash

echo "🚀 Deploying eShop to Kubernetes..."

# Create namespace
echo "📁 Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy infrastructure services first
echo "🗄️  Deploying infrastructure services..."
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f rabbitmq.yaml

# Wait for infrastructure to be ready
echo "⏳ Waiting for infrastructure services..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n eshop
kubectl wait --for=condition=available --timeout=300s deployment/redis -n eshop
kubectl wait --for=condition=available --timeout=300s deployment/rabbitmq -n eshop

# Deploy API services
echo "🔧 Deploying API services..."
kubectl apply -f identity-api.yaml
kubectl apply -f catalog-api.yaml
kubectl apply -f basket-api.yaml
kubectl apply -f ordering-api.yaml
kubectl apply -f webhooks-api.yaml
kubectl apply -f mobile-bff.yaml

# Wait for APIs to be ready
echo "⏳ Waiting for API services..."
kubectl wait --for=condition=available --timeout=300s deployment/identity-api -n eshop
kubectl wait --for=condition=available --timeout=300s deployment/catalog-api -n eshop
kubectl wait --for=condition=available --timeout=300s deployment/basket-api -n eshop

# Deploy web applications
echo "🌐 Deploying web applications..."
kubectl apply -f webapp.yaml
kubectl apply -f webhook-client.yaml

# Deploy gateway
echo "🚪 Deploying API gateway..."
kubectl apply -f nginx-gateway.yaml

# Wait for web apps and gateway
echo "⏳ Waiting for web applications and gateway..."
kubectl wait --for=condition=available --timeout=300s deployment/webapp -n eshop
kubectl wait --for=condition=available --timeout=300s deployment/nginx-gateway -n eshop

# Deploy ingress
echo "🌍 Deploying ingress..."
kubectl apply -f ingress.yaml

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📊 Checking deployment status..."
kubectl get pods -n eshop
echo ""
echo "🌐 Services:"
kubectl get services -n eshop
echo ""
echo "🚪 Ingress:"
kubectl get ingress -n eshop
echo ""
echo "🎯 Access Points:"
echo "  Main Application: http://localhost/"
echo "  Management:       http://localhost/management"
echo "  RabbitMQ:         http://localhost/rabbitmq"
echo "  Direct Services:  http://localhost/direct/[service]/"
echo ""
echo "🔍 To check logs: kubectl logs -f deployment/[service-name] -n eshop"
echo "🔧 To debug:      kubectl describe pod [pod-name] -n eshop"
