.PHONY: all build-backend build-frontend run-backend run-frontend dev clean test docker-up docker-down setup

all: build-backend build-frontend

build-backend:
	cd backend && go build -o bin/server ./cmd/main.go

build-frontend:
	cd frontend && npm run build

run-backend:
	cd backend && go run ./cmd/main.go

run-frontend:
	cd frontend && npm run dev

dev:
	@echo "Starting both backend and frontend..."
	@cd backend && go run ./cmd/main.go &
	@cd frontend && npm run dev &
	@wait

clean:
	rm -rf backend/bin frontend/dist

test:
	cd backend && go test -v -race -count=1 ./...

docker-up:
	docker compose up -d --build

docker-down:
	docker compose down

setup:
	@echo "=== Bishal Puja Sewa - Setup ==="
	@echo "1. Installing backend dependencies..."
	cd backend && go mod download
	@echo "2. Installing frontend dependencies..."
	cd frontend && npm install
	@echo "3. Building backend..."
	cd backend && go build -o bin/server ./cmd/main.go
	@echo "4. Building frontend..."
	cd frontend && npm run build
	@echo "Setup complete!"
	@echo "Run 'make dev' to start development servers"
	@echo "Or 'make docker-up' to run with Docker"
