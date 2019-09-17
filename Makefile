.DEFAULT_GOAL         := help
REPO                  := github.com/bukhavtsov/toolkit-log-service
BIN_PATH              ?= ./bin
SERVER_IMAGE_NAME     ?= server:latest
SERVER_CONTAINER_NAME ?= server_container
SERVER_SRC_PATH       ?= ./cmd/server/
SERVER_BIN_PATH       ?= $(BIN_PATH)/server/server
SERVER_DOCKER_PATH    ?= ./docker/server
CLIENT_IMAGE_NAME     ?= client:latest
CLIENT_CONTAINER_NAME ?= client_container
CLIENT_SRC_PATH       ?= ./cmd/client/
CLIENT_BIN_PATH       ?= $(BIN_PATH)/client/client
CLIENT_DOCKER_PATH    ?= ./docker/client

PHONY: help
help: ## makefile targets description
	@echo "Usage:"
	@egrep '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##/#-/' | column -t -s "#"

.PHONY: gen
gen:
	@echo '>>' gen toolkit-log-service
	@protoc --proto_path=./pkg/pb \
	--go_out=plugins=grpc:./pkg/pb service.proto

.PHONY: fmt
fmt: ## automatically formats Go source code
	@echo "Running 'go fmt ...'"
	@go fmt -x "$(REPO)/..."

.PHONY: build
build: fmt  ## compile package and dependencies for ./cmd/server/main.go and ./cmd/client/main.go
	@echo "Building server..."
	CGO_ENABLED=0 go build -o $(SERVER_BIN_PATH) $(SERVER_SRC_PATH)
	@echo "Building client..."
	CGO_ENABLED=0 go build -o $(CLIENT_BIN_PATH) $(CLIENT_SRC_PATH)

.PHONY: build-server
build-server: fmt ## compile package and dependencies for ./cmd/server/main.go
	@echo "Building server..."
	CGO_ENABLED=0 go build -o $(SERVER_BIN_PATH) $(SERVER_SRC_PATH)

.PHONY: build-client
build-client: fmt ## compile package and dependencies for ./cmd/client/main.go
	@echo "Building client..."
	CGO_ENABLED=0 go build -o $(CLIENT_BIN_PATH) $(CLIENT_SRC_PATH)

.PHONY: run-server
run-server: build-server ## execute server binary
	@echo "Running server..."
	$(SERVER_BIN_PATH)

.PHONY: run-client
run-client: build-client ## execute client binary
	@echo "Running client..."
	$(CLIENT_BIN_PATH)

.PHONY: image
image: build ## build images from Dockerfiles ./docker/server/Dockerfile, ./docker/client/Dockerfile
	@echo "Building server image..."
	cp $(SERVER_BIN_PATH) $(SERVER_DOCKER_PATH)
	@docker build -t $(SERVER_IMAGE_NAME) $(SERVER_DOCKER_PATH)
	rm $(SERVER_DOCKER_PATH)/server
	@echo "Building client image..."
	cp $(CLIENT_BIN_PATH) $(CLIENT_DOCKER_PATH)
	@docker build -t $(CLIENT_IMAGE_NAME) $(CLIENT_DOCKER_PATH)
	rm $(CLIENT_DOCKER_PATH)/client

.PHONY: clean
clean: ## remove binary, images server:latest, client:latest and dangling images
	@echo "Removing binary, image $(CLIENT_IMAGE_NAME), $(SERVER_IMAGE_NAME) and dangling images..."
	@rm $(SERVER_BIN_PATH) $(CLIENT_BIN_PATH) || echo "binary does not exist"
	@docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
	@docker rmi -f $(SERVER_IMAGE_NAME) || echo "$(SERVER_IMAGE_NAME) does not exist"
	@docker rmi -f $(CLIENT_IMAGE_NAME) || echo "$(CLIENT_IMAGE_NAME) does not exist"

.PHONY: run-image
run-image: image ## run new container server_container
	@echo "Starting container..."
	@docker run --rm --name $(CONTAINER_NAME) -it -p 1514:1514/udp $(IMAGE_NAME) || true