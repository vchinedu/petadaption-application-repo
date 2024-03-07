pipeline {
    agent any
    environment {
        NEXUS_USER = credentials('nexus-username')
        NEXUS_PASSWORD = credentials('nexus-password')
        NEXUS_REPO = credentials('nexus-repo')
    }
    stages {
        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build Artifact') {
            steps {
                sh 'mvn clean install -DskipTests -Dcheckstyle.skip'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $NEXUS_REPO/myapp:latest .'
            }
        }
        stage('Push Artifact to Nexus Repo') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic',
                classifier: '',
                file: 'target/spring-petclinic-2.4.2.war',
                type: 'war']],
                credentialsId: 'nexus-creds',
                groupId: 'Petclinic',
                nexusUrl: 'nexus.eamanzebuzz.com',
                nexusVersion: 'nexus3',
                protocol: 'https',
                repository: 'nexus-repo',
                version: '1.0'
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage('Log into Nexus Repo') {
            steps {
                sh 'docker login --username $NEXUS_USER --password $NEXUS_PASSWORD $NEXUS_REPO'
            }
        }
        stage('Push to Nexus Repo') {
            steps {
                sh 'docker push $NEXUS_REPO/myapp:latest'
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image $NEXUS_REPO/myapp:latest > trivy.txt"
            }
        }
        stage('Deploy to stage') {
            steps {
                sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@13.36.237.67 -o strictHostKeyChecking=no "ansible-playbook -i /etc/ansible/stage-hosts /etc/ansible/stage_playbook.yml"'
                }
            }
        }
        stage('check stage website availability') {
            steps {
                 sh "sleep 90"
                 sh "curl -s -o /dev/null -w \"%{http_code}\" https://stage.eamanzebuzz.com"
                script {
                    def response = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" https://stage.eamanzebuzz.com", returnStdout: true).trim()
                    if (response == "200") {
                        slackSend(color: 'good', message: "The stage petclinic website is up and running with HTTP status code ${response}.", tokenCredentialId: 'slack')
                    } else {
                        slackSend(color: 'danger', message: "The stage petclinic wordpress website appears to be down with HTTP status code ${response}.", tokenCredentialId: 'slack')
                    }
                }
            }
        }
        stage('Request for Approval') {
            steps {
                timeout(activity: true, time: 10) {
                    input message: 'Needs Approval ', submitter: 'admin'
                }
            }
        }
        stage('Deploy to prod') {
            steps {
                sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@13.36.237.67 -o strictHostKeyChecking=no "ansible-playbook -i /etc/ansible/prod-hosts /etc/ansible/prod_playbook.yml"'
                }
            }
        }
        stage('check prod website availability') {
            steps {
                 sh "sleep 90"
                 sh "curl -s -o /dev/null -w \"%{http_code}\" https://prod.eamanzebuzz.com"
                script {
                    def response = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" https://prod.eamanzebuzz.com", returnStdout: true).trim()
                    if (response == "200") {
                        slackSend(color: 'good', message: "The prod petclinic website is up and running with HTTP status code ${response}.", tokenCredentialId: 'slack')
                    } else {
                        slackSend(color: 'danger', message: "The prod petclinic wordpress website appears to be down with HTTP status code ${response}.", tokenCredentialId: 'slack')
                    }
                }
            }
        }
    }
}
