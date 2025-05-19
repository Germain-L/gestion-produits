.PHONY: help build build-migrations build-uploads push push-migrations push-uploads all login up down logs

# Variables
IMAGE_NAME = gestion-produits
VERSION ?= latest
REGISTRY = registry.germainleignel.com/library
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(VERSION)
MIGRATIONS_IMAGE = $(REGISTRY)/$(IMAGE_NAME)-migrations:$(VERSION)
UPLOADS_IMAGE = $(REGISTRY)/$(IMAGE_NAME)-uploads:$(VERSION)

help:
	@echo "Available targets:"
	@echo "  build           - Build the main Docker image"
	@echo "  build-migrations - Build the migrations Docker image"
	@echo "  build-uploads   - Build the uploads Docker image"
	@echo "  push            - Push all Docker images to the registry"
	@echo "  push-migrations - Push the migrations image to the registry"
	@echo "  push-uploads    - Push the uploads image to the registry"
	@echo "  all             - Build and push all images"
	@echo "  login           - Log in to the Docker registry"
	@echo "  up              - Start the application with docker-compose"
	@echo "  down            - Stop and remove the application"

# Build the Docker images
build:
	docker build -t $(IMAGE_NAME):$(VERSION) .

build-migrations:
	docker build -f Dockerfile.migrations -t $(IMAGE_NAME)-migrations:$(VERSION) .

build-uploads:
	docker build -f Dockerfile.uploads -t $(IMAGE_NAME)-uploads:$(VERSION) .

# Tag the images for the registry
tag:
	docker tag $(IMAGE_NAME):$(VERSION) $(FULL_IMAGE)
	docker tag $(IMAGE_NAME)-migrations:$(VERSION) $(MIGRATIONS_IMAGE)
	docker tag $(IMAGE_NAME)-uploads:$(VERSION) $(UPLOADS_IMAGE)

# Push the images to the registry
push: tag push-migrations push-uploads
	docker push $(FULL_IMAGE)

push-migrations:
	docker push $(MIGRATIONS_IMAGE)

push-uploads:
	docker push $(UPLOADS_IMAGE)

# Kubernetes namespace
NAMESPACE = gestion-produits

# Build and push all images
all: build build-migrations build-uploads push

# Log in to the Docker registry
login:
	docker login $(REGISTRY)

# Docker Compose commands
up:
	docker-compose up -d

down:
	docker-compose down

# Kubernetes apply commands
k8s-apply:
	kubectl apply -f k8s/01-db-pvc.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/02-db-deployment.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/03-db-service.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/04-app-pvc.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/05-app-deployment.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/06-app-service.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/07-app-certificate.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/08-app-ingress.yaml -n $(NAMESPACE)

# Delete all Kubernetes resources (except PVCs by default)
k8s-delete:
	@echo "Deleting Kubernetes resources..."
	kubectl delete -f k8s/08-app-ingress.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/07-app-certificate.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/06-app-service.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/05-app-deployment.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/04-app-pvc.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/03-db-service.yaml --ignore-not-found=true -n $(NAMESPACE)
	kubectl delete -f k8s/02-db-deployment.yaml --ignore-not-found=true -n $(NAMESPACE)
	@echo "Note: PVCs are preserved by default. Use 'make k8s-delete-all' to delete everything including PVCs"

# Delete all Kubernetes resources including PVCs (data will be lost!)
k8s-delete-all:
	@echo "WARNING: This will delete all resources including PVCs (data will be lost!)"
	@read -p "Are you sure? (y/n) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
	    make k8s-delete; \
	    kubectl delete pvc -l app=gestion-produits --ignore-not-found=true -n $(NAMESPACE); \
	    echo "All resources including PVCs have been deleted"; \
	fi

# Restart the application (deployment rollout)
k8s-restart:
	kubectl rollout restart deployment/gestion-produits-app -n $(NAMESPACE)

# Get pod status
k8s-status:
	@echo "=== Pods ==="
	kubectl get pods -n $(NAMESPACE) -l app=gestion-produits-app
	@echo "\n=== Services ==="
	kubectl get svc -n $(NAMESPACE) -l app=gestion-produits-app
	@echo "\n=== Ingress ==="
	kubectl get ingress -n $(NAMESPACE)

# Tail logs from the application
k8s-logs:
	kubectl logs -f -l app=gestion-produits-app -n $(NAMESPACE) --tail=100 --all-containers

# Port-forward to the application service
k8s-forward:
	kubectl port-forward svc/gestion-produits-app 8080:80 -n $(NAMESPACE)

# Show logs
logs:
	docker-compose logs -f