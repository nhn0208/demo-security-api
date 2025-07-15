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

        stage('ZAP Scan (BOLA)') {
            steps {
                dir('C:\\Xanh\\tttn\\ZAP\\ZAP_2.16.1_Crossplatform\\ZAP_2.16.1') {
                    bat """
                        echo Running ZAP automation scan...
                        zap.bat -cmd -autorun "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\security-ci\\zap\\zap-automation.yaml"
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
            archiveArtifacts artifacts: "zap\\zap-reports\\zap-bola-report.html", fingerprint: true
        }
    }
}
