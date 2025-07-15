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


        stage('Run ZAP with BOLA Script') {
            steps {
                dir("${env.ZAP_HOME}") {
                    bat """
                        echo Running ZAP with TestBOLA.js script...
                        zap.bat -cmd -autorun zap-autorun.yaml -addoninstall scripts -config scripts.scriptsAutoLoad=true
                    """
                }
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
