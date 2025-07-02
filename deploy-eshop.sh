#!/bin/bash

set -e

echo "🚀 Deploying eShop to Kubernetes with custom domain support..."
echo "🌐 Target domain: webapp.tkjpedia.com"
echo ""

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    echo "⏳ Waiting for $deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
    if [ $? -eq 0 ]; then
        echo "✅ $deployment is ready"
    else
        echo "❌ $deployment failed to become ready"
        kubectl describe deployment/$deployment -n $namespace
        return 1
    fi
}

# Function to check pod status
check_pods() {
    echo "📊 Current pod status:"
    kubectl get pods -n eshop -o wide
    echo ""
}

# Step 1: Create namespace
echo "📁 Creating namespace..."
kubectl apply -f k8s/namespace.yaml
echo ""

# Step 2: Deploy infrastructure services
echo "🗄️  Deploying infrastructure services..."
echo "   - PostgreSQL database"
kubectl apply -f k8s/postgres.yaml

echo "   - Redis cache"
kubectl apply -f k8s/redis.yaml

echo "   - RabbitMQ message broker"
kubectl apply -f k8s/rabbitmq.yaml
echo ""

# Wait for infrastructure
echo "⏳ Waiting for infrastructure services to be ready..."
wait_for_deployment "postgres" "eshop"
wait_for_deployment "redis" "eshop"
wait_for_deployment "rabbitmq" "eshop"
echo ""

# Step 3: Deploy API services
echo "🔧 Deploying API services..."
echo "   - Identity API"
kubectl apply -f k8s/identity-api-fixed.yaml

echo "   - Catalog API"
kubectl apply -f k8s/catalog-api-fixed.yaml

echo "   - Basket API"
kubectl apply -f k8s/basket-api-fixed.yaml

echo "   - Ordering API"
kubectl apply -f k8s/ordering-api-fixed.yaml
echo ""

# Wait for API services
echo "⏳ Waiting for API services to be ready..."
wait_for_deployment "identity-api" "eshop"
wait_for_deployment "catalog-api" "eshop"
wait_for_deployment "basket-api" "eshop"
wait_for_deployment "ordering-api" "eshop"
echo ""

# Step 4: Deploy web application
echo "🌐 Deploying web application..."
kubectl apply -f k8s/webapp-fixed.yaml
echo ""

# Wait for web app
echo "⏳ Waiting for web application to be ready..."
wait_for_deployment "webapp" "eshop"
echo ""

# Step 5: Deploy ingress
echo "🚪 Deploying ingress controller..."
kubectl apply -f k8s/ingress-complete.yaml
echo ""

# Step 6: Final status check
echo "✅ Deployment completed!"
echo ""
echo "📊 Final deployment status:"
check_pods

echo "🌐 Services:"
kubectl get services -n eshop
echo ""

echo "🚪 Ingress:"
kubectl get ingress -n eshop
echo ""

echo "🎯 Access Points:"
echo "  Main Application: http://webapp.tkjpedia.com"
echo "  Identity Server:  http://webapp.tkjpedia.com/identity"
echo "  Catalog API:      http://webapp.tkjpedia.com/api/catalog"
echo "  Basket API:       http://webapp.tkjpedia.com/api/basket"
echo "  Ordering API:     http://webapp.tkjpedia.com/api/orders"
echo ""

echo "🔍 Useful commands:"
echo "  Check logs:       kubectl logs -f deployment/[service-name] -n eshop"
echo "  Debug pod:        kubectl describe pod [pod-name] -n eshop"
echo "  Port forward:     kubectl port-forward service/[service-name] 8080:8080 -n eshop"
echo "  Shell into pod:   kubectl exec -it deployment/[service-name] -n eshop -- /bin/bash"
echo ""

echo "🔧 Troubleshooting:"
echo "  If authentication fails, check Identity API logs:"
echo "  kubectl logs -f deployment/identity-api -n eshop"
echo ""
echo "  If services can't connect, check network policies and service discovery:"
echo "  kubectl get endpoints -n eshop"
echo ""

# Check if ingress controller is installed
echo "🔍 Checking ingress controller..."
if kubectl get pods -n ingress-nginx | grep -q "ingress-nginx-controller"; then
    echo "✅ NGINX Ingress Controller is running"
else
    echo "⚠️  NGINX Ingress Controller not found. Install it with:"
    echo "   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
fi
echo ""

echo "🎉 eShop deployment complete! Visit http://webapp.tkjpedia.com to access the application."
