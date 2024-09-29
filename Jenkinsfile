pipeline{
    agent any
    stages{
        stage('checkout from GIT'){
            steps{
               git branch: 'main', url: 'https://github.com/ulrich-sun/jenkins-test-ci-cd.git'
            }
        }
        stage('Terraform Init'){
            agent { 
                    docker { 
                            image 'jenkins/jnlp-agent-terraform'  
                    } 
                }
          environment {
            AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
            AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            PRIVATE_AWS_KEY = credentials('private_aws_key')
          }  
            steps{
                sh 'terraform init'
            }
        }
        stage('Terraform Apply'){
           steps{
                sh 'terraform apply --auto-approve'
           }
        }
    }   
}