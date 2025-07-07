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


        stage('Generate ZAP Config with JWT') {
            steps {
                powershell 'zap\\generate-zap-config.ps1'
            }
        }

        stage('Run ZAP Scan') {
    steps {
        bat 'java -Xmx512m -jar "C:\\Xanh\\tttn\\ZAP\\ZAP_2.16.1_Crossplatform\\ZAP_2.16.1\\zap-2.16.1.jar" -cmd -port 8095 -autorun zap\\zap-automation.yaml'
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
            echo 'Clear backend...'
            bat 'taskkill /F /IM java.exe || exit 0'
        }
    }
}
