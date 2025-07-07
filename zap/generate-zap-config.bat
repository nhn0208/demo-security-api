@echo off
setlocal enabledelayedexpansion

echo Waiting for backend to be ready...

:wait_loop
powershell -Command "try { iwr http://localhost:8080/api/auth/login -UseBasicParsing -TimeoutSec 3 } catch { exit 1 }"
IF %ERRORLEVEL% NEQ 0 (
    timeout /T 3 >nul
    goto wait_loop
)

echo Backend is ready!

REM --- Gửi login request và lưu token ---
powershell -Command ^
    "$response = iwr -Uri http://localhost:8080/api/auth/login -Method Post -Body '{\"username\":\"client\",\"password\":\"client123\"}' -ContentType 'application/json';" ^
    "$token = ($response.Content | ConvertFrom-Json).token;" ^
    "Set-Content -Path zap\\jwt-token.txt -Value $token"

REM --- Đọc token vào biến môi trường ---
set /p TOKEN=<zap\jwt-token.txt

echo JWT Token is: %TOKEN%

REM --- Tạo file zap-automation.yaml ---
> zap\zap-automation.yaml (
    echo parameters:
    echo   - name: target
    echo     value: 'http://localhost:8080'
    echo   - name: JWT
    echo     value: '%TOKEN%'
)

REM --- Ghép phần scan còn lại (static YAML template) ---
type zap\static-config-part.yaml >> zap\zap-automation.yaml

echo zap-automation.yaml đã được tạo thành công!
