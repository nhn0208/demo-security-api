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
                    powershell 'Start-Process -FilePath "java" -ArgumentList "-jar target/api-0.0.1-SNAPSHOT.jar" -NoNewWindow'
                }
                sleep time: 10, unit: 'SECONDS'
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
