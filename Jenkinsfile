pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds')
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git url: 'https://github.com/Fox-R-fox/3T-APP.git'
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
