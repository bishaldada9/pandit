#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bishal Puja Sewa - Setup Script for Windows/PowerShell
.DESCRIPTION
    Automated setup for the Secure Hindu Ritual Service & Pandit Booking Platform
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Bishal Puja Sewa - Setup Script (PowerShell)" -ForegroundColor Cyan
Write-Host "  Secure Hindu Ritual Service & Pandit Booking Platform" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow

try {
    $goVersion = go version
    Write-Host "  [OK] Go $($goVersion)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Go is not installed. Install Go 1.24+ from https://go.dev/dl/" -ForegroundColor Red
    exit 1
}

try {
    $nodeVersion = node --version
    Write-Host "  [OK] Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Node.js is not installed. Install Node.js 20+ from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = npm --version
    Write-Host "  [OK] npm $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] npm is not installed." -ForegroundColor Red
    exit 1
}

$dockerAvailable = $false
try {
    $dockerVersion = docker --version
    Write-Host "  [OK] $dockerVersion" -ForegroundColor Green
    $dockerAvailable = $true
} catch {
    Write-Host "  [WARN] Docker not found (optional - required for PostgreSQL/Redis)" -ForegroundColor Yellow
}

# Setup environment
Write-Host ""
Write-Host "[2/6] Setting up environment configuration..." -ForegroundColor Yellow

if (-not (Test-Path "backend\.env")) {
    Copy-Item "backend\.env.example" "backend\.env"
    Write-Host "  [OK] Created backend\.env from .env.example" -ForegroundColor Green
    Write-Host "  [WARN] Update backend\.env with your production values" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] backend\.env already exists" -ForegroundColor Green
}

# Install backend dependencies
Write-Host ""
Write-Host "[3/6] Installing backend dependencies..." -ForegroundColor Yellow
Set-Location backend
go mod download
Write-Host "  [OK] Backend dependencies installed" -ForegroundColor Green
Set-Location $scriptDir

# Install frontend dependencies
Write-Host ""
Write-Host "[4/6] Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location frontend
npm install
Write-Host "  [OK] Frontend dependencies installed" -ForegroundColor Green
Set-Location $scriptDir

# Build
Write-Host ""
Write-Host "[5/6] Building project..." -ForegroundColor Yellow

Set-Location backend
if (-not (Test-Path "bin")) { New-Item -ItemType Directory -Path "bin" -Force | Out-Null }
go build -o bin\server .\cmd\main.go
Write-Host "  [OK] Backend built (backend\bin\server.exe)" -ForegroundColor Green
Set-Location $scriptDir

Set-Location frontend
npx vite build
Write-Host "  [OK] Frontend built (frontend\dist\)" -ForegroundColor Green
Set-Location $scriptDir

# Start database services if Docker is available
Write-Host ""
Write-Host "[6/6] Starting services..." -ForegroundColor Yellow
if ($dockerAvailable) {
    Write-Host "  Starting PostgreSQL and Redis via Docker..." -ForegroundColor Yellow
    docker compose up -d postgres redis 2>&1 | Out-Null
    Write-Host "  [OK] Database services started" -ForegroundColor Green
    Write-Host "  Waiting for database to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Run the application:" -ForegroundColor White
Write-Host ""
Write-Host "  Terminal 1: cd backend && go run ./cmd/main.go" -ForegroundColor Yellow
Write-Host "  Terminal 2: cd frontend && npm run dev" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Or using Docker:" -ForegroundColor White
Write-Host "  docker compose up -d" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Access:" -ForegroundColor White
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor Yellow
Write-Host "  Backend:  http://localhost:8080" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Default Credentials (after seeding):" -ForegroundColor White
Write-Host "  Admin:     admin@bishalpujasewa.com / AdminPass123!" -ForegroundColor Yellow
Write-Host "  Pandit:    pandit.ram@example.com / PanditPass123!" -ForegroundColor Yellow
Write-Host "  Customer:  customer@example.com / CustomerPass123!" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

pause
