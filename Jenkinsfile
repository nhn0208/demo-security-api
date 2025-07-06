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

        stage('Generate ZAP Config with JWT') {
            steps {
                bat 'zap\\generate-zap-config.bat'
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
