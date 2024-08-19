pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds')
        GITHUB_CREDENTIALS = credentials('git-hub')
    }
    stages {
        stage('Install Prerequisites') {
            steps {
                script {
                    sh '''
                    if ! [ -x "$(command -v docker)" ]; then
                        curl -fsSL https://get.docker.com -o get-docker.sh
                        sh get-docker.sh
                        sudo usermod -aG docker $USER
                        newgrp docker
                    fi
                    if ! [ -x "$(command -v kubectl)" ]; then
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        sudo mv kubectl /usr/local/bin/
                    fi
                    if ! [ -x "$(command -v terraform)" ]; then
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                        sudo apt-get update && sudo apt-get install terraform -y
                    fi
                    '''
                }
            }
        }
        stage('Checkout Code') {
            steps {
                script {
                    git credentialsId: 'git-hub', url: 'https://github.com/Fox-R-fox/3T-APP.git'
                }
            }
        }
        stage('Build Docker Images') {
            steps {
                script {
                    sh 'docker build -t foxe03/frontend:latest ./docker/frontend'
                    sh 'docker build -t foxe03/backend:latest ./docker/backend'
                }
            }
        }
        stage('Push Docker Images') {
            steps {
                script {
                    sh '''
                    docker login -u ${DOCKER_HUB_CREDENTIALS_USR} -p ${DOCKER_HUB_CREDENTIALS_PSW}
                    docker push foxe03/frontend:latest
                    docker push foxe03/backend:latest
                    '''
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        terraform init -input=false terraform/
                        terraform apply -auto-approve terraform/
                        '''
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                    kubectl apply -f kubernetes/frontend-deployment.yaml
                    kubectl apply -f kubernetes/backend-deployment.yaml
                    kubectl apply -f kubernetes/service.yaml
                    kubectl apply -f kubernetes/ingress.yaml
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
