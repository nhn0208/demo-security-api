pipeline {
    agent any

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
                    powershell 'Start-Process -FilePath "java" -ArgumentList "-jar target/api-0.0.1-SNAPSHOT.jar"'
                }
                sleep time: 10, unit: 'SECONDS'
            }
        }

        stage('Scan BOLA (Manual Script)') {
            steps {
                powershell 'zap\\test-BOLA-vul.ps1'
                archiveArtifacts artifacts: 'zap\\zap-reports\\zap-bola-log.txt', fingerprint: true
            }
        }
    }

    post {
        always {
            echo 'Clear backend...'
            bat 'taskkill /F /IM java.exe || exit 0'
        }
    }
}
