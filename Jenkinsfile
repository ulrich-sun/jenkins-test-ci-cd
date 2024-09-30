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
        stage('Install Nginx with Ansible') {
            agent {
                docker {
                    image 'registry.gitlab.com/robconnolly/docker-ansible:latest'  // Utiliser une image Ansible
                }
            }
            steps {
                script {
                    def instanceIP = readFile('instance_ip.txt').trim()
                    echo "Installer Nginx sur l'instance avec IP : ${instanceIP}"
                    echo " CHanger les permissions de la clé"
                    sh 'chmod 400 sun.pem'
                    
                    // Créer un fichier d'inventaire pour Ansible
                    writeFile file: 'inventory.ini', text: "[web]\n${instanceIP} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=sun.pem"

                    // Exécuter le playbook Ansible
                    sh 'ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i inventory.ini install_nginx.yml'
                }
            }
        }
        stage('Deploy Kubernetes Manifests') {
            agent {
                docker {
                    image 'bitnami/kubectl:latest'  // Utiliser une image contenant kubectl
                }
            }
            steps {
                script {
                    // Lire l'IP de l'instance
                    def instanceIP = readFile('instance_ip.txt').trim()
                    echo "Déploiement des manifests Kubernetes sur le cluster K3s avec IP : ${instanceIP}"

                    // Configurer kubectl pour accéder au cluster K3s
                    sh """
                    ssh -o StrictHostKeyChecking=no -i sun.pem ubuntu@${instanceIP} "sudo cat /etc/rancher/k3s/k3s.yaml" > kubeconfig.yaml
                    """
                    // Configurer kubectl pour utiliser le fichier kubeconfig
                    sh 'export KUBECONFIG=kubeconfig.yaml'

                    // Déployer les manifests Kubernetes
                    sh 'kubectl apply -f deployment.yml'
                }
            }
        }
    }
}
