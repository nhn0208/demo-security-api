pipeline {
    agent any

    environment {
        ZAP_HOME = 'C:\\Program Files\\ZAP\\Zed Attack Proxy'
        BACKEND_JAR = 'api\\target\\api-0.0.1-SNAPSHOT.jar'
        BOLA_SCRIPT = 'zap\\scripts\\TestBOLA.js'
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
                sleep time: 30, unit: 'SECONDS'
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
stage('Check ZAP Alerts') {
    steps {
        script {
            // Gọi API ZAP để lấy danh sách cảnh báo
            def batOutput = bat(
                script: 'curl -s http://localhost:8090/JSON/alert/view/alerts/',
                returnStdout: true
            ).trim()

            // Parse JSON bằng readJSON (an toàn với sandbox)
            def json = readJSON text: batOutput

            // Lọc các cảnh báo BOLA
            def bolaAlerts = json.alerts.findAll { it.name == 'BOLA vulnerability' }

            if (bolaAlerts.size() > 0) {
                echo " Found ${bolaAlerts.size()} BOLA vulnerability alerts!"
                bolaAlerts.each { a ->
                    echo " ${a.alert} at ${a.url}"
                }
                error(" Pipeline failed due to detected BOLA vulnerability")
            } else {
                echo " No BOLA vulnerabilities detected."
            }
        }
    }
}


}
}
