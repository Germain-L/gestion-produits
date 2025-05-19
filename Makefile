.PHONY: help build push all login

# Variables
IMAGE_NAME = gestion-produits
VERSION ?= latest
REGISTRY = registry.germainleignel.com/library
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(VERSION)

help:
	@echo "Available targets:"
	@echo "  build     - Build the Docker image"
	@echo "  push      - Push the Docker image to the registry"
	@echo "  all       - Build and push the image"
	@echo "  login     - Log in to the Docker registry"
	@echo "  up        - Start the application with docker-compose"
	@echo "  down      - Stop and remove the application"

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(VERSION) .

# Tag the image for the registry
tag:
	docker tag $(IMAGE_NAME):$(VERSION) $(FULL_IMAGE)

# Push the image to the registry
push: tag
	docker push $(FULL_IMAGE)

# Build and push the image
all: build push

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
