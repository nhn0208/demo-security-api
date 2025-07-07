Write-Host "[INFO] Checking backend ..."

$maxRetries = 10
$waitSeconds = 5
$retryCount = 0
$backendReady = $false

do {
    try {
        $res = Invoke-WebRequest -Uri "http://localhost:8080/v1/api-docs" -UseBasicParsing -TimeoutSec 5
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
} | ConvertTo-Json

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

# Tạo file zap-automation.yaml
$yaml = @"
env:
  contexts:
    - name: jwt-context
      urls:
        - http://localhost:8080
      includePaths:
        - http://localhost:8080/api/auth/.*
        - http://localhost:8080/api/users/.*
        - http://localhost:8080/api/orders/.*
      authentication:
        method:
          type: httpHeader
          parameters:
            header: Authorization
            value: Bearer $token
        verification:
          method: response
          loggedInRegex: ".*"
          loggedOutRegex: ".*"
      sessionManagement:
        method: cookie
      users:
        - name: clientUser
          credentials: {}
  vars: {}

jobs:
  - type: spider
    name: spider-users-orders
    parameters:
      context: jwt-context
      user: clientUser
      maxDuration: 2

  - type: passiveScan-wait
    name: passive-scan

  - type: activeScan
    name: active-users-orders
    parameters:
      context: jwt-context
      user: clientUser
      policy: Default Policy
      maxRuleDurationInMins: 2

  - type: report
    name: generate-html-report
    parameters:
      template: traditional-html
      reportDir: zap-reports
      reportFile: zap-report.html
"@

$yaml | Set-Content -Path "zap\zap-automation.yaml" -Encoding UTF8

Write-Host "[INFO] File zap-automation.yaml is created successfully"