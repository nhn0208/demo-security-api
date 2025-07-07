@echo off

curl -s -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"client\", \"password\":\"client123\"}" > response.json

for /f "tokens=*" %%i in ('powershell -Command "(Get-Content response.json | ConvertFrom-Json).token"') do set TOKEN=%%i

echo Token is: %TOKEN%

echo parameters: > zap/zap-automation.yaml
echo   - name: target >> zap/zap-automation.yaml
echo     value: 'http://localhost:8080' >> zap/zap-automation.yaml
echo   - name: JWT >> zap/zap-automation.yaml
echo     value: '%TOKEN%' >> zap/zap-automation.yaml

type zap/static-config-part.yaml >> zap/zap-automation.yaml
