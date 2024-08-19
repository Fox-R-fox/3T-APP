pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds')
        AWS_CREDENTIALS = credentials('aws')
        GITHUB_CREDENTIALS = credentials('git-hub')
    }
    stages {
        stage('Install Prerequisites') {
            steps {
                script {
                    // Install Docker
                    sh '''
                    if ! [ -x "$(command -v docker)" ]; then
                        echo "Docker is not installed. Installing Docker..."
                        curl -fsSL https://get.docker.com -o get-docker.sh
                        sh get-docker.sh
                        sudo usermod -aG docker $USER
                    fi
                    '''

                    // Install Kubectl
                    sh '''
                    if ! [ -x "$(command -v kubectl)" ]; then
                        echo "kubectl is not installed. Installing kubectl..."
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        sudo mv kubectl /usr/local/bin/
                    fi
                    '''

                    // Install Terraform
                    sh '''
                    if ! [ -x "$(command -v terraform)" ]; then
                        echo "Terraform is not installed. Installing Terraform..."
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                        sudo apt-get update && sudo apt-get install terraform
                    fi
                    '''
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git credentialsId: 'git-hub', url: 'https://github.com/your-repo/three-tier-app.git'
            }
        }
        stage('Build Docker Images') {
            steps {
                script {
                    // Build Docker images for frontend and backend
                    sh 'docker build -t foxe03/frontend:latest ./docker/frontend'
                    sh 'docker build -t foxe03/backend:latest ./docker/backend'
                }
            }
        }
        stage('Push Docker Images') {
            steps {
                script {
                    // Log in to Docker Hub and push the images
                    sh 'docker login -u ${DOCKER_HUB_CREDENTIALS_USR} -p ${DOCKER_HUB_CREDENTIALS_PSW}'
                    sh 'docker push foxe03/frontend:latest'
                    sh 'docker push foxe03/backend:latest'
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                script {
                    // Initialize Terraform and apply the configuration
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws'
                    ]]) {
                        sh 'terraform init -input=false terraform/'
                        sh 'terraform apply -auto-approve terraform/'
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Deploy the application to the Kubernetes cluster
                    sh 'kubectl apply -f kubernetes/frontend-deployment.yaml'
                    sh 'kubectl apply -f kubernetes/backend-deployment.yaml'
                    sh 'kubectl apply -f kubernetes/service.yaml'
                    sh 'kubectl apply -f kubernetes/ingress.yaml'
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
