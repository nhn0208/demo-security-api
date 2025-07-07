pipeline {
    agent any

    environment {
        ZAP_HOME = 'C:\\Users\\Admin\\ZAP' // Cấu hình đúng nơi bạn cài OWASP ZAP
    }

    stages {
        stage('Build Project') {
            steps {
                dir('api') {
                    bat 'mvnw.cmd clean package -DskipTests'
                }
            }
        }

        stage('Start Backend API') {
            steps {
                dir('api') {
                    bat 'start "" java -jar target\\*.jar'
                }
                sleep time: 30, unit: 'SECONDS'
            }
        }

	stage('Check Backend is Ready') {
    	steps {
        	powershell '''
        	$maxRetries = 10
        	$waitSeconds = 5
        	$url = "http://localhost:8080/v1/api-docs"
        	$retryCount = 0

        	do {
            	try {
                	$res = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
                	if ($res.StatusCode -eq 200) {
                    	Write-Host "[INFO] Backend is ready."
                    	break
                	}
            	} catch {
               	 	Write-Host "[INFO] Backend not ready... retry in $waitSeconds seconds"
            	}
            	Start-Sleep -Seconds $waitSeconds
            	$retryCount++
        	} while ($retryCount -lt $maxRetries)

        	if ($retryCount -eq $maxRetries) {
            	Write-Error "[ERROR] Backend not responding after multiple retries!"
            	exit 1
        }'''
    }
}


        stage('Generate ZAP Config with JWT') {
            steps {
                powershell 'zap\\generate-zap-config.ps1'
            }
        }

        stage('Run ZAP Scan') {
            steps {
                bat "\"%ZAP_HOME%\\zap.bat\" -cmd -autorun zap\\zap-automation.yaml"
            }
        }

        stage('Archive Report') {
            steps {
                archiveArtifacts artifacts: 'zap-reports\\zap-report.html', fingerprint: true
            }
        }
    }

    post {
        always {
            echo 'Dọn dẹp tiến trình backend...'
            bat 'taskkill /F /IM java.exe || exit 0'
        }
    }
}
