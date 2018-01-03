pipeline {
    agent any

    toos {
        maven 'maven3'
        jdk 'jdk8'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building..'
                sh 'mvn clean verify package'
            }
        }
    }
}