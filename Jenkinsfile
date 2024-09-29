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
                    image 'jenkins/jnlp-agent-terraform'  // Assurez-vous que cette image contient Terraform
                }
            }
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
                PRIVATE_AWS_KEY = credentials('private_aws_key')
            }
            steps {
                script {
                    // Initialiser Terraform
                    sh 'terraform init'
                    
                    // Vérifier si Terraform est installé
                    sh 'which terraform || echo "Terraform not found"'
                    sh 'terraform version'
                    
                    // Appliquer la configuration Terraform
                    sh 'terraform apply --auto-approve'
                    
                    // Récupérer l'adresse IP publique de l'instance
                    def instanceIP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
                    echo "L'adresse IP publique de l'instance est : ${instanceIP}"
                }
            }
        }
    }
}
