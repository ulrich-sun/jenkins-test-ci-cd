pipeline {
    agent any
    stages {
        stage('Checkout from GIT') {
            steps {
                git branch: 'main', url: 'https://github.com/ulrich-sun/jenkins-test-ci-cd.git'
            }
        }
        stage('Terraform Init and Apply') {
            agent {
                docker {
                    image 'jenkins/jnlp-agent-terraform'  // Remplacez par votre image personnalisée
                }
            }
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
                PRIVATE_AWS_KEY = credentials('private_aws_key')
            }
            steps {
                sh 'terraform init'
                sh 'which terraform || echo "Terraform not found"'
                sh 'terraform version'
                sh 'terraform apply --auto-approve'
            }
        }
        stage('Get Public IP') {
            steps {
                script {
                    def instanceIP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
                    echo "L\'adresse IP publique de l\'instance est : ${instanceIP}"
                }
            }
        }
    }
}
