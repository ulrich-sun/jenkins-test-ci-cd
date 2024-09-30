/* import shared library. */
@Library('ulrich-shared-library')_

pipeline {
    agent any
    stages {
        stage('Checkout from GIT') {
            steps {
                git branch: 'dev', url: 'https://github.com/ulrich-sun/jenkins-test-ci-cd.git'
            }
        }
        stage('Terraform Init and Apply') {
            agent {
                docker {
                    image 'jenkins/jnlp-agent-terraform'
                }
            }
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            }
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform apply --auto-approve'
                    
                    // Récupérer l'adresse IP publique de l'instance
                    def instanceIP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
                    echo "L'adresse IP publique de l'instance est : ${instanceIP}"

                    // Stocker l'IP dans un fichier pour l'étape suivante
                    writeFile file: 'instance_ip.txt', text: instanceIP
                }
            }
        }
        stage('Install K3s with Ansible') {
            agent {
                docker {
                    image 'registry.gitlab.com/robconnolly/docker-ansible:latest'
                }
            }
            steps {
                script {
                    def instanceIP = readFile('instance_ip.txt').trim()
                    echo "Installer K3s sur l'instance avec IP : ${instanceIP}"
                    
                    // Créer un fichier d'inventaire pour Ansible
                    writeFile file: 'inventory.ini', text: "[k3s]\n${instanceIP} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=sun.pem"
                    echo "CHange key permission"
                    sh 'chmod 400 sun.pem'
                    // Exécuter le playbook Ansible pour installer K3s
                    sh 'ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i inventory.ini install_k3s.yml'
                }
            }
        }
        stage('Configure kubectl for Remote Access') {
            steps {
                script {
                    // def instanceIP = readFile('instance_ip.txt').trim()
                    echo "Configurer kubectl pour accéder à K3s sur l'instance..."

                    // Récupérer le fichier kubeconfig
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i sun.pem ubuntu@${instanceIP} "sudo cat /etc/rancher/k3s/k3s.yaml" > kubeconfig.yaml
                    '''
                    
                    // Modifier le kubeconfig pour utiliser l'IP publique
                    sh "sed -i 's/127.0.0.1/${instanceIP}/' kubeconfig.yaml"

                    // Définir la variable d'environnement KUBECONFIG
                    sh 'export KUBECONFIG=$(pwd)/kubeconfig.yaml'
                }
            }
        }
        stage('Deploy to K3s') {
            steps {
                script {
                    echo "Déployer sur K3s..."
                    
                    // Déployer l'application avec kubectl
                    sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    '''
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                script {
                    input message: 'Vérifiez que le déploiement est fonctionnel. Appuyez sur "Proceed" pour continuer.'
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    echo "Supprimer l'environnement..."
                    
                    // Supprimer l'instance EC2
                    sh 'terraform destroy --auto-approve'
                    
                    echo "Environnement supprimé."
                }
            }
        }
    }
    post {
        always {
            script {
                /*sh '''
                    echo "Manually Cleaning workspace after starting"
                    rm -f vault.key id_rsa id_rsa.pub password devops.pem public_ip.txt
                ''' */
                slackNotifier currentBuild.result
            }
        }
    } 
}