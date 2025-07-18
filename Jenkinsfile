pipeline {
    agent any

    environment {
        ZAP_HOME = 'C:\\Program Files\\ZAP\\Zed Attack Proxy'
        BACKEND_JAR = 'api\\target\\api-0.0.1-SNAPSHOT.jar'
	ZAP_LOG_DIR = "${env.WORKSPACE}\\zap\\zap-reports"
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
                    bat '''
                        powershell -Command "Start-Process 'zap.bat' -ArgumentList '-daemon -port 8090 -config api.disablekey=true -config scripts.scriptsAutoLoad=true' -WindowStyle Hidden"
                    '''
                }
                sleep time: 15, unit: 'SECONDS'
            }
        }

        stage('Check PORT') {
            steps {
                bat '''
    echo === Checking if ZAP (port 8090) is running ===
    netstat -ano | findstr :8090 || echo ZAP proxy not listening on port 8090!

    echo === Checking if Backend API (port 8080) is running ===
    netstat -ano | findstr :8080 || echo Backend API not listening on port 8080!
'''
            }
        }

        stage('Trigger ZAP Scan') {
    steps {
        bat """
            curl -x http://127.0.0.1:8090 ^
                 -X GET http://127.0.0.1:8080/api/users/2 ^
                 -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjbGllbnQiLCJpYXQiOjE3NTIwNzU0ODcsImV4cCI6MTc1MjA3OTA4N30.pHh85D4foJmPvLk0pxPvPr6RySFU9MyBn4H5GRF7tgo"
        """
    }
}
stage('Copy log vào workspace') {
    steps {
        bat 'copy /Y "C:\\Xanh\\tttn\\demo\\zap\\zap-reports\\zap-bola-log.txt" "zap\\zap-reports\\zap-bola-log.txt"'
    }
}

stage('Check BOLA Log File') {
    steps {
        script {
            def logPath = "zap/zap-reports/zap-bola-log.txt"
            def exists = fileExists(logPath)

            if (!exists) {
                error(" Log file not found: ${logPath}")
            }

            def content = readFile(logPath)
            echo " BOLA Log:\n" + content

            if (content.contains("BOLA vulnerability")) {
                error(" BOLA vulnerability detected! Failing pipeline.")
            } else {
                echo " No BOLA vulnerabilities detected in log."
            }
        }
    }
}

stage('Publish ZAP Report') {
    steps {
        publishHTML(target: [
            reportDir: "zap\\zap-reports",
            reportFiles: "zap-bola-log.txt",
            reportName: 'ZAP BOLA Report'
        ])
    }
}

}
}
