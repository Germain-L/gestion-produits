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

# Build and push all images
all: build build-migrations build-uploads push

# Log in to the Docker registry
login:
	docker login $(REGISTRY)

# Start the application with docker-compose
up:
	docker-compose up -d

# Stop and remove the application
down:
	docker-compose down

# Show logs
logs:
	docker-compose logs -f