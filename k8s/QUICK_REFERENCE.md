# eShop Kubernetes - Quick Reference

## 🚀 Essential Commands

### Deploy
```bash
./deploy.sh                    # Full deployment
kubectl apply -f .             # Apply all manifests
```

### Access
```bash
# Forward HTTPS port
kubectl port-forward service/ingress-nginx-controller 8443:443 -n ingress-nginx

# URLs:
# https://localhost:8443 (Host: webapp.tkjpedia.com)
# https://localhost:8443 (Host: identity.tkjpedia.com)
```

### Status Check
```bash
kubectl get pods -n eshop                    # Check all pods
kubectl get services -n eshop                # Check services  
kubectl get ingress -n eshop                 # Check ingress
kubectl get secrets -n eshop | grep tls      # Check SSL certs
```

### Logs
```bash
kubectl logs deployment/webapp -n eshop -f           # WebApp logs
kubectl logs deployment/identity-api -n eshop -f     # Identity logs
kubectl logs deployment/basket-api -n eshop -f       # Basket logs
kubectl logs deployment/catalog-api -n eshop -f      # Catalog logs
kubectl logs deployment/ordering-api -n eshop -f     # Ordering logs
```

### Restart Services
```bash
kubectl rollout restart deployment/webapp -n eshop
kubectl rollout restart deployment/identity-api -n eshop
kubectl rollout restart deployment/basket-api -n eshop
```

### Scale Services
```bash
kubectl scale deployment webapp --replicas=2 -n eshop
kubectl scale deployment catalog-api --replicas=3 -n eshop
```

### Debug
```bash
kubectl describe pod <pod-name> -n eshop     # Pod details
kubectl exec -it <pod-name> -n eshop -- bash # Shell into pod
kubectl port-forward pod/<pod-name> 8080:8080 -n eshop # Direct pod access
```

### SSL Management
```bash
# Check certificate expiry
echo | openssl s_client -servername webapp.tkjpedia.com -connect localhost:8443 2>/dev/null | openssl x509 -noout -dates

# Recreate SSL secrets
kubectl delete secret webapp-tls-secret identity-tls-secret -n eshop
kubectl create secret tls webapp-tls-secret --cert=../tls/tkjpedia.com/fullchain1.pem --key=../tls/tkjpedia.com/privkey1.pem -n eshop
kubectl create secret tls identity-tls-secret --cert=../tls/tkjpedia.com/fullchain1.pem --key=../tls/tkjpedia.com/privkey1.pem -n eshop
```

### Cleanup
```bash
./cleanup.sh                  # Clean removal
kubectl delete namespace eshop # Force removal
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `namespace.yaml` | Creates eshop namespace |
| `postgres.yaml` | PostgreSQL database |
| `redis.yaml` | Redis cache |
| `rabbitmq.yaml` | RabbitMQ message broker |
| `db-init-complete.yaml` | Database initialization |
| `catalog-api-fixed.yaml` | Product catalog service |
| `basket-api-config-fixed.yaml` | Shopping basket service |
| `ordering-api-config-fixed.yaml` | Order management service |
| `identity-api-config-https-fixed.yaml` | Authentication service |
| `webapp-config-https-fixed.yaml` | Web application |
| `webapp-ingress-ssl-fixed.yaml` | WebApp HTTPS ingress |
| `identity-ingress-ssl-fixed.yaml` | Identity HTTPS ingress |

## 🔑 Default Credentials

```
Username: alice@alice
Password: Pass123$

Username: bob@bob
Password: Pass123$
```

## 🌐 Service URLs (Internal)

| Service | URL | Port |
|---------|-----|------|
| WebApp | `http://webapp:8080` | 8080 |
| Identity API | `http://identity-api:8080` | 8080 |
| Catalog API | `http://catalog-api:8080` | 8080 |
| Basket API | `http://basket-api:8080` | 8080 |
| Ordering API | `http://ordering-api:8080` | 8080 |
| PostgreSQL | `postgres:5432` | 5432 |
| Redis | `redis:6379` | 6379 |
| RabbitMQ | `rabbitmq:5672` | 5672 |

## 🔍 Health Checks

```bash
# Test identity service
curl -k -H "Host: identity.tkjpedia.com" https://localhost:8443/.well-known/openid-configuration

# Test webapp
curl -k -H "Host: webapp.tkjpedia.com" https://localhost:8443/

# Test APIs (requires authentication)
curl -k -H "Host: webapp.tkjpedia.com" https://localhost:8443/api/catalog/items
```

## 🚨 Common Issues

| Issue | Solution |
|-------|----------|
| 502 Bad Gateway | Check ingress buffer sizes (already configured) |
| Authentication fails | Verify SSL certificates and identity URL |
| Pod CrashLoopBackOff | Check logs: `kubectl logs <pod> -n eshop` |
| Service unreachable | Check service and endpoint: `kubectl get svc,ep -n eshop` |
| SSL certificate invalid | Recreate TLS secrets with valid certificates |

## 📊 Resource Requirements

| Service | CPU Request | Memory Request | CPU Limit | Memory Limit |
|---------|-------------|----------------|-----------|--------------|
| WebApp | 300m | 512Mi | 600m | 1Gi |
| Identity API | 200m | 256Mi | 500m | 512Mi |
| Catalog API | 200m | 256Mi | 500m | 512Mi |
| Basket API | 200m | 256Mi | 500m | 512Mi |
| Ordering API | 200m | 256Mi | 500m | 512Mi |
| PostgreSQL | 500m | 1Gi | 1000m | 2Gi |
| Redis | 100m | 128Mi | 200m | 256Mi |
| RabbitMQ | 200m | 512Mi | 400m | 1Gi |
