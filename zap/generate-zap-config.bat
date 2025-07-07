@echo off
setlocal enabledelayedexpansion

REM === Kiểm tra backend đã khởi động ===
echo [INFO] Đang chờ backend sẵn sàng...

set RETRIES=10
set WAIT=5
set /a COUNT=0
:WAIT_LOOP
curl -s http://localhost:8080/actuator/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Backend chưa sẵn sàng... chờ %WAIT% giây
    timeout /T %WAIT% /NOBREAK >nul
    set /a COUNT+=1
    if !COUNT! LSS %RETRIES% (
        goto WAIT_LOOP
    ) else (
        echo [ERROR] Backend không phản hồi sau %RETRIES% lần thử!
        exit /b 1
    )
)

echo [INFO] Backend đã sẵn sàng.

REM === Gọi API đăng nhập để lấy token ===
echo [INFO] Đang lấy JWT token...

for /f "usebackq tokens=*" %%i in (`curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"client\",\"password\":\"client123\"}" ^| powershell -Command "$input | ConvertFrom-Json | Select -ExpandProperty token"`) do (
    set TOKEN=%%i
)

if "%TOKEN%"=="" (
    echo [ERROR] Không lấy được JWT token.
    exit /b 1
)

echo [INFO] Token lấy được: %TOKEN%

REM === Tạo zap-automation.yaml bằng cách nối file cấu hình tĩnh và token ===
(
    type zap\static-config-part.yaml
    echo authentication:
    echo   method:
    echo     type: httpHeader
    echo     parameters:
    echo       header: Authorization
    echo       value: Bearer %TOKEN%
) > zap\zap-automation.yaml

echo [INFO] File zap-automation.yaml đã được tạo xong.
exit /b 0
