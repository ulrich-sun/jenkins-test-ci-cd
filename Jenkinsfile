pipeline {
    agent none
    stages {
        stage('Terraform Apply') {
            agent {
                docker {
                    image 'hashicorp/terraform:latest'
                    args '-v $HOME/.aws:/root/.aws'  // Montez le répertoire AWS si nécessaire
                }
            }
            environment {
                AWS_REGION = 'us-east-1'
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
                PRIVATE_AWS_KEY = credentials('private_aws_key')
            }
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Generate Inventory') {
            agent {
                docker {
                    image 'hashicorp/terraform:latest'
                }
            }
            steps {
                sh 'terraform output -json > inventory.json'
            }
        }
        stage('Ansible Provisioning') {
            agent {
                docker {
                    image 'willhallonline/ansible:latest'
                    args '-v $HOME/.ssh:/root/.ssh'  // Montez le répertoire SSH si nécessaire
                }
            }
            steps {
                // Assurez-vous que l'inventaire est bien formaté
                sh 'ansible-playbook -i inventory.json setup.yml'
            }
        }
    }
}
