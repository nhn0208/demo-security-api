Write-Host "[INFO] Checking backend readiness..."

$maxRetries = 10
$waitSeconds = 5
$retryCount = 0
$backendReady = $false

do {
    try {
        $res = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5
        if ($res.StatusCode -eq 200) {
            Write-Host "[INFO] Backend is ready!"
            $backendReady = $true
            break
        }
    } catch {
        Write-Host "[INFO] Backend not ready... retrying in $waitSeconds seconds."
    }
    Start-Sleep -Seconds $waitSeconds
    $retryCount++
} while ($retryCount -lt $maxRetries)

if (-not $backendReady) {
    Write-Error "[ERROR] Could not connect to backend after $maxRetries attempts."
    exit 1
}

Write-Host "[INFO] Logging in to get JWT token..."

$loginBody = @{
    username = "client"
    password = "client123"
} | ConvertTo-Json -Depth 3

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json"

    $token = $response.token
} catch {
    Write-Error "[ERROR] Login failed: $_"
    exit 1
}

if (-not $token) {
    Write-Error "[ERROR] Token not received!"
    exit 1
}

Write-Host "[INFO] Token obtained: $token"

# Read static YAML part
$staticPartPath = "zap\static-config-part.yaml"
$finalYamlPath = "zap\zap-automation.yaml"

if (-Not (Test-Path $staticPartPath)) {
    Write-Error "[ERROR] static-config-part.yaml not found!"
    exit 1
}

$staticPart = Get-Content $staticPartPath -Raw

# Create dynamic authentication block
$authPart = @"
authentication:
  method:
    type: httpHeader
    parameters:
      header: Authorization
      value: Bearer $token
"@

# Combine and save to final file
$combined = $staticPart + "`r`n" + $authPart
$combined | Set-Content $finalYamlPath -Encoding UTF8

Write-Host "[INFO] File zap-automation.yaml has been created successfully at: $finalYamlPath"
