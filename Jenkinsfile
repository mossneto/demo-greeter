pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk8'
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean compile'
                script {
                    def pom = readMavenPom file: 'pom.xml'
                    VERSION = pom.version
                }
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn verify'
            }
        }

        stage('Push Jar' {
            steps {
                sh 'mvn deploy'
            }
        }

        stage('QA Deploy') {
            when { branch "develop" }
            steps {
                sh "cd terraform/develop & terraform apply -var-file=~/qa.tfvars -var greeter_version=${VERSION} & cd ../.."
            }
        }

        stage('Staging Deploy') {
            when { branch "master" }
            steps {
                sh "cd terraform/staging & terraform apply -var-file=~/staging.tfvars -var greeter_version=${VERSION} & cd ../.."
            }
        }
    }
}