pipeline {
    agent any
    stages {
        stage('Terraform Apply') {
            agent {
                docker {
                    image 'hashicorp/terraform:latest'
                    args '-v $HOME/.aws:/root/.aws'  // Montez le répertoire AWS credentials si nécessaire
                }
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
