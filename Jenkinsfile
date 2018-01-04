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

        stage('Dev Deploy') {
            when { branch "develop" }
            steps {
                sh 'echo ...'
            }
        }
    }
}