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
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn verify'
            }
        }

        stage('Test') {
            steps {
                pom = readMavenPom("pom.xml")
                sh 'echo ${pom.version}'
            }
        }

        stage('QA Deploy') {
            when { branch "develop" }
            steps {
                sh 'cd terraform/develop & terraform apply -var-file=~/qa.tfvars -var greeter_version=${env.} & cd ../..'
            }
        }

        stage('Staging Deploy') {
            when { branch "master" }
            steps {
                sh 'cd terraform/staging & terraform apply -var-file=~/staging.tfvars -var greeter_version=${env.} & cd ../..'
            }
        }
    }
}