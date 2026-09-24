pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = "deepu09567/dockerwebsite"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/deepubhakuni5-create/Dockerwebsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        dockerImage.push("${IMAGE_TAG}")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Update k8s.yaml Image Tag') {
            steps {
                sh """
                    sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|' k8s.yaml
                """
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh 'kubectl apply -f k8s.yaml'
            }
        }
    }

    post {
        success {
            echo "✅ Deployed ${IMAGE_NAME}:${IMAGE_TAG} successfully."
        }
        failure {
            echo "❌ Pipeline failed — check console output."
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}
