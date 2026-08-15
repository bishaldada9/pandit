#!/bin/bash
set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Bishal Puja Sewa - Setup Script                          ║"
echo "║     Secure Hindu Ritual Service & Pandit Booking Platform    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

command -v go >/dev/null 2>&1 || { echo -e "${RED}Error: Go is not installed. Install Go 1.24+ from https://go.dev/dl/${NC}"; exit 1; }
echo -e "  ${GREEN}✓${NC} Go $(go version | grep -oP 'go\K[0-9]+\.[0-9]+')"

command -v node >/dev/null 2>&1 || { echo -e "${RED}Error: Node.js is not installed. Install Node.js 20+ from https://nodejs.org/${NC}"; exit 1; }
echo -e "  ${GREEN}✓${NC} Node.js $(node --version)"

command -v npm >/dev/null 2>&1 || { echo -e "${RED}Error: npm is not installed.${NC}"; exit 1; }
echo -e "  ${GREEN}✓${NC} npm $(npm --version)"

if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Docker & Docker Compose"
    DOCKER_AVAILABLE=true
else
    echo -e "  ${YELLOW}⚠${NC} Docker not found (optional - required for PostgreSQL/Redis)"
    DOCKER_AVAILABLE=false
fi

# Setup environment
echo ""
echo -e "${YELLOW}[2/6] Setting up environment configuration...${NC}"
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
    echo -e "  ${GREEN}✓${NC} Created backend/.env from .env.example"
    echo -e "  ${YELLOW}⚠${NC} Please update backend/.env with your production values"
else
    echo -e "  ${GREEN}✓${NC} backend/.env already exists"
fi

# Install backend dependencies
echo ""
echo -e "${YELLOW}[3/6] Installing backend dependencies...${NC}"
cd backend
go mod download
echo -e "  ${GREEN}✓${NC} Backend dependencies installed"
cd ..

# Install frontend dependencies
echo ""
echo -e "${YELLOW}[4/6] Installing frontend dependencies...${NC}"
cd frontend
npm install
echo -e "  ${GREEN}✓${NC} Frontend dependencies installed"
cd ..

# Build
echo ""
echo -e "${YELLOW}[5/6] Building project...${NC}"
cd backend
go build -o bin/server ./cmd/main.go
echo -e "  ${GREEN}✓${NC} Backend built (backend/bin/server)"
cd ..

cd frontend
npx vite build
echo -e "  ${GREEN}✓${NC} Frontend built (frontend/dist/)"
cd ..

# Start services
echo ""
echo -e "${YELLOW}[6/6] Starting services...${NC}"
if [ "$DOCKER_AVAILABLE" = true ]; then
    echo -e "  Starting PostgreSQL and Redis via Docker..."
    docker compose up -d postgres redis
    echo -e "  ${GREEN}✓${NC} Database services started"
    echo ""
    echo -e "  Waiting for database to be ready..."
    sleep 3
fi

# Start application
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  ${GREEN}Setup Complete!${NC}                                                ║"
echo "║                                                               ║"
echo "║  Run the application:                                        ║"
echo "║                                                               ║"
echo "║  Terminal 1: cd backend && go run ./cmd/main.go              ║"
echo "║  Terminal 2: cd frontend && npm run dev                      ║"
echo "║                                                               ║"
echo "║  Or using Docker:                                            ║"
echo "║  docker compose up -d                                        ║"
echo "║                                                               ║"
echo "║  Access:                                                      ║"
echo "║  Frontend: http://localhost:3000                              ║"
echo "║  Backend:  http://localhost:8080                              ║"
echo "║                                                               ║"
echo "║  Default Credentials (after seeding):                        ║"
echo "║  Admin:     admin@bishalpujasewa.com / AdminPass123!         ║"
echo "║  Pandit:    pandit.ram@example.com / PanditPass123!          ║"
echo "║  Customer:  customer@example.com / CustomerPass123!          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
