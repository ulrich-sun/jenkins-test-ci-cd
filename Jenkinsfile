pipeline {
    agent none
    stages {
        stage('Terraform Apply') {
            agent {
                docker {
                    image 'hashicorp/terraform:latest'
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
                sh 'terraform apply -target=local_file.inventory'
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
                ansiblePlaybook credentialsId: 'ansible-ssh', inventory: 'inventory', playbook: 'setup.yml'
            }
        }
    }
}
