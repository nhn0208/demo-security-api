pipeline {
    agent any

    environment {
        ZAP_HOME = '/opt/zap'
    }

    stages {
        stage('Build Project') {
            steps {
                dir('api') {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }

        stage('Start Backend API') {
            steps {
                dir('api') {
                    sh 'nohup java -jar target/*.jar &'
                }
                sleep time: 30, unit: 'SECONDS'
            }
        }

        stage('Generate ZAP Config with JWT') {
            steps {
                sh 'chmod +x zap/generate-zap-config.sh'
                sh './zap/generate-zap-config.sh'
            }
        }

        stage('Run ZAP Scan') {
            steps {
                sh "${ZAP_HOME}/zap.sh -cmd -autorun zap/zap-automation.yaml"
            }
        }

        stage('Archive Report') {
            steps {
                archiveArtifacts artifacts: 'zap-reports/zap-report.html', fingerprint: true
            }
        }
    }
}
