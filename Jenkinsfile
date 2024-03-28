pipeline {
    agent any
    stages {
        stage('Code analisys stage') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage('Quality gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true 
                }
            }
        }
        stage('Testing') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Build artefacts') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Push artifacts to nexus-repo') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic',
                classifier: '',
                file: 'target/spring-petclinic-2.4.2.war',
                type: 'war']],
                credentialsId: 'nexus-creds',
                groupId: 'Petclinic',
                nexusUrl: '13.41.184.65:8081',
                nexusVersion: 'nexus3',
                protocol: 'http',
                repository: 'nexus-repo',
                version: '1.0'
            }
        }
        stage('Create docker image') {
            steps {
                sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@13.40.123.168 -o strictHostKeyChecking=no "ansible-playbook /opt/docker/docker-image.yml"'
                }
            }
        }
        stage('Create container') {
            steps {
                sshagent(['ansible-key']) {
                    sh 'ssh -t -t ec2-user@13.40.123.168 -o strictHostKeyChecking=no "ansible-playbook /opt/docker/docker-container.yml"'
                }
            }
        }
        stage('Create Slack notification') {
            steps {
                slackSend channel: 'Cloudhight',
                message: 'Successful application deployment',
                teamDomain: '04th-march-pet-adoption-containerization-project-using-jenkins-pipeline',
                tokenCredentialId: 'slack'
            }
        }
    }
}
