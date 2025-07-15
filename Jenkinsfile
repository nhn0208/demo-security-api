pipeline {
    agent any

    environment {
        ZAP_HOME = 'C:\\Xanh\\tttn\\ZAP\\ZAP_2.16.1_Crossplatform\\ZAP_2.16.1'
        ZAP_TEMPLATE = 'zap\\zap-automation-template.yaml'
        ZAP_CONFIG   = 'zap\\zap-automation.yaml'
        ZAP_REPORT   = 'zap\\zap-reports\\zap-bola-report.html'
        BACKEND_JAR  = 'api\\target\\api-0.0.1-SNAPSHOT.jar'
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
                powershell """
                    Start-Process -FilePath "java" -ArgumentList "-jar ${BACKEND_JAR}" -WindowStyle Hidden
                """
                sleep time: 10, unit: 'SECONDS'
            }
        }

        stage('Generate JWT Token & Prepare YAML') {
            steps {
                script {
                    def loginPayload = '{"username":"client","password":"client123"}'
                    def token = powershell(script: """
                        \$body = '${loginPayload}'
                        \$response = Invoke-RestMethod -Uri http://localhost:8080/api/auth/login -Method Post -Body \$body -ContentType 'application/json'
                        \$response.token
                    """, returnStdout: true).trim()

                    echo "JWT Token: ${token}"

                    def template = readFile("${ZAP_TEMPLATE}")
                    def filledYaml = template.replace('{{token}}', token)
                    writeFile file: "${ZAP_CONFIG}", text: filledYaml
                }
            }
        }

        stage('ZAP Scan (BOLA)') {
            steps {
                dir("${ZAP_HOME}") {
                    bat """
                        echo Running ZAP automation scan with token...
                        zap.bat -cmd -autorun "${env.WORKSPACE}\\${ZAP_CONFIG}"
                    """
                }
            }
        }

        stage('Publish ZAP Report') {
            steps {
                publishHTML(target: [
                    reportDir: "zap\\zap-reports",
                    reportFiles: "zap-bola-report.html",
                    reportName: 'ZAP BOLA Security Report',
                    keepAll: true,
                    alwaysLinkToLastBuild: true
                ])
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "${ZAP_REPORT}", fingerprint: true
        }
    }
}
