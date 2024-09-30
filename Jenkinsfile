/* import shared library. */
@Library('ulrich-shared-library')_

pipeline {
    agent any
    environment {
        INSTANCE_IP = ''
    }
    stages {
    //     stage('Checkout from GIT') {
    //         steps {
    //             git branch: 'dev', url: 'https://github.com/ulrich-sun/jenkins-test-ci-cd.git'
    //         }
    //     }
    //     stage('Terraform Init and Apply') {
    //         agent {
    //             docker {
    //                 image 'jenkins/jnlp-agent-terraform'
    //             }
    //         }
    //         environment {
    //             AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
    //             AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    //         }
    //         steps {
    //             script {
    //                 try {
    //                     sh 'terraform init'
    //                     sh 'terraform apply --auto-approve'
                        
    //                     // Récupérer l'adresse IP publique de l'instance
    //                     INSTANCE_IP = sh(script: 'terraform output -raw instance_ip', returnStdout: true).trim()
    //                     echo "L'adresse IP publique de l'instance est : ${INSTANCE_IP}"

    //                     // Stocker l'IP dans un fichier pour l'étape suivante
    //                     writeFile file: 'instance_ip.txt', text: INSTANCE_IP
    //                 } catch (Exception e) {
    //                     error "Échec de l'initialisation ou de l'application Terraform : ${e.message}"
    //                 }
    //             }
    //         }
    //     }
        // stage('Install K3s with Ansible') {
        //     agent {
        //         docker {
        //             image 'registry.gitlab.com/robconnolly/docker-ansible:latest'
        //         }
        //     }
        //     steps {
        //         script {
        //             if (fileExists('instance_ip.txt')) {
        //                 def INSTANCE_IP = readFile('instance_ip.txt').trim()
        //                 echo "Installer K3s sur l'instance avec IP : ${INSTANCE_IP}"
                        
        //                 // Créer un fichier d'inventaire pour Ansible
        //                 writeFile file: 'inventory.ini', text: "[k3s]\n${INSTANCE_IP} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=sun.pem"
        //                 echo "Changer les permissions de la clé"
        //                 sh 'chmod 400 sun.pem'
                        
        //                 // Exécuter le playbook Ansible pour installer K3s
        //                 sh 'ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i inventory.ini install_k3s.yml'
        //             } else {
        //                 error "Le fichier instance_ip.txt n'existe pas."
        //             }
        //         }
        //     }
        // }
        stage('Configure kubectl for Remote Access') {
            steps {
                script {
                    // Lire l'IP de l'instance
                    def instanceIP = readFile('instance_ip.txt').trim()
                    echo "Configurer kubectl pour accéder à K3s sur l'instance avec IP : ${instanceIP}"

                    // Afficher le contenu de l'IP pour débogage
                    sh "cat instance_ip.txt"

                    // Vérifier si l'IP n'est pas vide
                    if (!instanceIP) {
                        error "L'adresse IP de l'instance est vide."
                    }

                    // Récupérer le fichier kubeconfig
                    try {
                        // Récupérer le contenu de kubeconfig avant la connexion SSH
                        def kubeconfigContent = sh(script: "ssh -o StrictHostKeyChecking=no -i sun.pem ubuntu@${instanceIP} 'sudo cat /etc/rancher/k3s/k3s.yaml'", returnStdout: true).trim()
                        
                        // Écrire le contenu dans kubeconfig.yaml
                        writeFile file: 'kubeconfig.yaml', text: kubeconfigContent
                        echo "Fichier kubeconfig récupéré avec succès."

                        // Afficher le contenu du fichier kubeconfig pour vérification
                        echo "Contenu de kubeconfig.yaml :"
                        echo kubeconfigContent
                    } catch (Exception e) {
                        error "Échec de la récupération du fichier kubeconfig : ${e.message}"
                    }
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
                slackNotifier currentBuild.result, "Le pipeline a terminé avec le résultat : ${currentBuild.result}."
            }
        }
    }
}
