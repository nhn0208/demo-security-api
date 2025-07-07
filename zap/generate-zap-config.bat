#!/bin/bash

JWT=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"client","password":"client123"}' | jq -r '.token')
echo "JWT token lấy được: $JWT"

cat <<EOF > zap/zap-automation.yaml
env:
  vars:
    API_BASE: http://localhost:8080
    JWT_TOKEN: ${JWT}

  contexts:
    - name: jwt-context
      urls:
        - \${API_BASE}
      includePaths:
        - '\${API_BASE}/api/users/.*'
        - '\${API_BASE}/api/orders/.*'
      authentication:
        method: httpHeader
        parameters:
          headerName: Authorization
          headerValue: 'Bearer \${JWT_TOKEN}'
      sessionManagement:
        method: httpAuthSession
      users:
        - name: jwt-user
          credentials: {}
          parameters: {}

jobs:
  - type: spider
    name: spider-users-orders
    parameters:
      context: jwt-context
      maxDuration: 2

  - type: passiveScan-wait
    name: passive-scan

  - type: activeScan
    name: active-users-orders
    parameters:
      context: jwt-context
      policy: Default Policy
      maxRuleDurationInMins: 2

  - type: report
    name: generate-html-report
    parameters:
      template: traditional-html
      reportDir: zap-reports
      reportFile: zap-report.html
EOF