@echo off
setlocal enabledelayedexpansion

REM --- Wait for backend ---
echo Waiting for backend to be ready...
:loop
curl -s http://localhost:8080/api/auth/login > nul
IF %ERRORLEVEL% NEQ 0 (
    timeout /T 3 > nul
    goto loop
)
echo Backend is ready!

REM --- Call login API and save response ---
curl -s -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"client\", \"password\":\"client123\"}" > response.json

REM --- Extract token using PowerShell ---
for /f "delims=" %%i in ('powershell -Command "(Get-Content response.json | ConvertFrom-Json).token"') do set "TOKEN=%%i"

echo Token is: %TOKEN%
if "%TOKEN%"=="" (
    echo Failed to extract token!
    exit /b 1
)

REM --- Write zap-automation.yaml ---
echo parameters: > zap/zap-automation.yaml
echo   - name: target >> zap/zap-automation.yaml
echo     value: 'http://localhost:8080' >> zap/zap-automation.yaml
echo   - name: JWT >> zap/zap-automation.yaml
echo     value: '%TOKEN%' >> zap/zap-automation.yaml

REM --- Append static config ---
type zap/static-config-part.yaml >> zap/zap-automation.yaml

echo Done generating ZAP config.
