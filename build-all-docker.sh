#!/bin/bash

# eShop Docker Build Script
# This script builds all Docker images for the eShop microservices
# Run from the root directory of the eShop solution

set -e  # Exit on any error

echo "🚀 Starting eShop Docker Build Process..."
echo "📍 Current directory: $(pwd)"

# Check if we're in the right directory
if [ ! -f "Directory.Packages.props" ]; then
    echo "❌ Error: Please run this script from the eShop root directory"
    echo "   The Directory.Packages.props file should be in the current directory"
    exit 1
fi

# Define services to build
declare -A services=(
    ["src/Catalog.API/Dockerfile"]="catalog-api"
    ["src/Basket.API/Dockerfile"]="basket-api"
    ["src/Identity.API/Dockerfile"]="identity-api"
    ["src/Ordering.API/Dockerfile"]="ordering-api"
    ["src/Webhooks.API/Dockerfile"]="webhooks-api"
    ["src/Mobile.Bff.Shopping/Dockerfile"]="mobile-bff"
    ["src/WebApp/Dockerfile"]="webapp"
    ["src/WebhookClient/Dockerfile"]="webhook-client"
    ["src/OrderProcessor/Dockerfile"]="order-processor"
    ["src/PaymentProcessor/Dockerfile"]="payment-processor"
)

# Build counters
total_services=${#services[@]}
successful_builds=0
failed_builds=0

echo "📦 Building $total_services services..."
echo ""

# Build each service
for dockerfile in "${!services[@]}"; do
    tag="${services[$dockerfile]}"
    echo "🔨 Building $tag..."
    echo "   Dockerfile: $dockerfile"
    
    if docker build -f "$dockerfile" -t "$tag:latest" . --quiet; then
        echo "✅ Successfully built $tag"
        ((successful_builds++))
    else
        echo "❌ Failed to build $tag"
        ((failed_builds++))
    fi
    echo ""
done

# Summary
echo "📊 Build Summary:"
echo "   Total services: $total_services"
echo "   Successful: $successful_builds"
echo "   Failed: $failed_builds"

if [ $failed_builds -eq 0 ]; then
    echo "🎉 All services built successfully!"
    echo ""
    echo "📋 Available images:"
    for tag in "${services[@]}"; do
        echo "   - $tag:latest"
    done
    echo ""
    echo "💡 Next steps:"
    echo "   1. Set up infrastructure services (PostgreSQL, Redis, RabbitMQ)"
    echo "   2. Create docker-compose.yml for orchestration"
    echo "   3. Configure environment variables"
    echo "   4. Run the services"
else
    echo "⚠️  Some builds failed. Check the output above for details."
    exit 1
fi
