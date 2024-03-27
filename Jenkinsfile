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
    }
}
