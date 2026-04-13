pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/suhassg25/addressbook.git'
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'jenkinsecr'
        ECR_PUBLIC_REPO_URI = '409171460696.dkr.ecr.ap-south-1.amazonaws.com/jenkinsecr'
        IMAGE_TAG = 'latest'
        AWS_ACCOUNT_ID = '409171460696'
        IMAGE_URI = "${ECR_PUBLIC_REPO_URI}:${IMAGE_TAG}"
        EKS_CLUSTER = 'my-cluster'
    }

    stages {
        
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }
    
        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'master'
            }
        }

        stage('Build') {
            steps {
                script {
                    sh '''
                        echo "Building Java application..."
                        mvn clean -B -Denforcer.skip=true package
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    sh '''
                        echo "Logging into AWS ECR..."
                        aws ecr get-login-password --region ap-south-1 \
                        | docker login --username AWS --password-stdin 409171460696.dkr.ecr.ap-south-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        echo "Building Docker image..."
                        docker build -t ${IMAGE_URI} .
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh '''
                        echo "Pushing Docker image to ECR..."
                        docker push ${IMAGE_URI}
                    '''
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                        echo "Updating kubeconfig..."
                        mkdir -p /var/lib/jenkins/.kube
                        aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER --kubeconfig /var/lib/jenkins/.kube/config
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        echo "Applying Kubernetes manifests..."
                        kubectl apply -f deployment.yaml --validate=false
                        kubectl apply -f servicelb.yaml --validate=false
                    '''
                }
            }
        }
        
    }
    
    post {
        success {
            echo "Docker image pushed to ECR successfully and deployed addressbook to EKS cluster ."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
