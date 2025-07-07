Write-Host "[INFO] Đang kiểm tra backend có hoạt động chưa..."

$maxRetries = 10
$waitSeconds = 5
$retryCount = 0

do {
    try {
        $res = Invoke-WebRequest -Uri http://localhost:8080/actuator/health -UseBasicParsing -TimeoutSec 3
        if ($res.StatusCode -eq 200) {
            Write-Host "[INFO] Backend đã sẵn sàng."
            break
        }
    } catch {
        Write-Host "[INFO] Backend chưa sẵn sàng... chờ $waitSeconds giây"
    }
    Start-Sleep -Seconds $waitSeconds
    $retryCount++
} while ($retryCount -lt $maxRetries)

if ($retryCount -eq $maxRetries) {
    Write-Error "[ERROR] Không thể kết nối đến backend!"
    exit 1
}

Write-Host "[INFO] Đang lấy JWT token..."

$loginBody = @{
    username = "client"
    password = "client123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri http://localhost:8080/api/auth/login -Method POST -Body $loginBody -ContentType "application/json"
$token = $response.token

if (-not $token) {
    Write-Error "[ERROR] Không lấy được token!"
    exit 1
}

Write-Host "[INFO] Token lấy được: $token"

$staticPart = Get-Content "zap\static-config-part.yaml"
$authPart = @"
authentication:
  method:
    type: httpHeader
    parameters:
      header: Authorization
      value: Bearer $token
"@

$combined = $staticPart + "`n" + $authPart
$combined | Set-Content "zap\zap-automation.yaml"

Write-Host "[INFO] File zap-automation.yaml đã được tạo thành công."
