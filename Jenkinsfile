pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/suhassg25/addressbook.git'
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'sample/jenkinspush'
        ECR_PUBLIC_REPO_URI = '409171460696.dkr.ecr.ap-south-1.amazonaws.com/sample/jenkinspush'
        IMAGE_TAG = 'latest'
        AWS_ACCOUNT_ID = '409171460696'
        IMAGE_URI = "${ECR_PUBLIC_REPO_URI}:${IMAGE_TAG}"
    }

    stages {
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
    }
    
    post {
        success {
            echo "Docker image pushed to ECR successfully and deployed."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
