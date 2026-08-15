@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo     Bishal Puja Sewa - Setup Script (Windows)
echo     Secure Hindu Ritual Service ^& Pandit Booking Platform
echo ============================================================
echo.

REM Check prerequisites
echo [1/6] Checking prerequisites...

where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Go is not installed. Install Go 1.24+ from https://go.dev/dl/
    pause
    exit /b 1
)
for /f "tokens=3" %%i in ('go version') do set GOVERSION=%%i
echo   [OK] Go !GOVERSION!

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Node.js is not installed. Install Node.js 20+ from https://nodejs.org/
    pause
    exit /b 1
)
echo   [OK] Node.js

where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: npm is not installed.
    pause
    exit /b 1
)
echo   [OK] npm

REM Setup environment
echo.
echo [2/6] Setting up environment configuration...
if not exist backend\.env (
    copy backend\.env.example backend\.env >nul
    echo   [OK] Created backend\.env from .env.example
    echo   [WARN] Update backend\.env with your production values
) else (
    echo   [OK] backend\.env already exists
)

REM Install backend dependencies
echo.
echo [3/6] Installing backend dependencies...
cd backend
go mod download
echo   [OK] Backend dependencies installed
cd ..

REM Install frontend dependencies
echo.
echo [4/6] Installing frontend dependencies...
cd frontend
call npm install
echo   [OK] Frontend dependencies installed
cd ..

REM Build
echo.
echo [5/6] Building project...
cd backend
if not exist bin mkdir bin
go build -o bin\server .\cmd\main.go
echo   [OK] Backend built (backend\bin\server.exe)
cd ..

cd frontend
call npx vite build
echo   [OK] Frontend built (frontend\dist\)
cd ..

REM Summary
echo.
echo ============================================================
echo   Setup Complete!
echo.
echo   Run the application:
echo.
echo   Terminal 1: cd backend ^&^& go run ./cmd/main.go
echo   Terminal 2: cd frontend ^&^& npm run dev
echo.
echo   Or using Docker:
echo   docker compose up -d
echo.
echo   Access:
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:8080
echo.
echo   Default Credentials (after seeding):
echo   Admin:     admin@bishalpujasewa.com / AdminPass123!
echo   Pandit:    pandit.ram@example.com / PanditPass123!
echo   Customer:  customer@example.com / CustomerPass123!
echo ============================================================
echo.

pause
