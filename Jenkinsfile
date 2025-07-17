pipeline {
    agent any

    environment {
        ZAP_HOME = 'C:\\Xanh\\tttn\\ZAP\\ZAP_2.16.1_Crossplatform\\ZAP_2.16.1'
        BACKEND_JAR = 'api\\target\\api-0.0.1-SNAPSHOT.jar'
        BOLA_LOG = 'zap\\zap-reports\\zap-bola-log.txt'
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
stage('Start ZAP Proxy') {
    steps {
        dir("${env.ZAP_HOME}") {
            powershell """
                 Start-Process -FilePath "zap.bat" -ArgumentList "-daemon -port 8090 -addoninstall scripts -config scripts.scriptsAutoLoad=true" -WindowStyle Hidden
            """
        }
        sleep time: 30, unit: 'SECONDS'
    }
}


        stage('Check ZAP Proxy') {
            steps {
                bat 'netstat -ano | findstr :8090 || echo ZAP proxy not listening!'
            }
        }


stage('Trigger ZAP Scan') {
    steps {
        bat """
            curl -x http://localhost:8090 ^
                 -X GET http://localhost:8080/api/users/2 ^
                 -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjbGllbnQiLCJpYXQiOjE3NTIwNzU0ODcsImV4cCI6MTc1MjA3OTA4N30.pHh85D4foJmPvLk0pxPvPr6RySFU9MyBn4H5GRF7tgo"
        """
    }
}


        stage('Publish Log Report') {
            steps {
                script {
                    def exists = fileExists("${BOLA_LOG}")
                    if (exists) {
                        echo "ZAP log found:"
                        def content = readFile("${BOLA_LOG}")
                        echo content
                    } else {
                        echo "Log file not found: ${BOLA_LOG}"
                    }
                }
            }
        }

	stage('Publish ZAP Report') {
            steps {
                publishHTML(target: [
                    reportDir: "zap\\zap-reports",
                    reportFiles: "zap-bola-log.txt",
                    reportName: 'ZAP BOLA Security Report',
                    keepAll: true,
                    alwaysLinkToLastBuild: true
                ])
            }
        }

    }

    post {
        always {
            archiveArtifacts artifacts: "${BOLA_LOG}", fingerprint: true
        }
    }
}
