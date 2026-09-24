pipeline {
    agent any

    environment {
        IMAGE_NAME = "deepu09567/dockerwebsite"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'

                git branch: 'main',
                    url: 'https://github.com/deepubhakuni5-create/Dockerwebsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"

                bat """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Logging in to Docker Hub and pushing image...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    bat """
                        docker login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%"
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Update k8s.yaml Image Tag') {
            steps {
                echo "Updating k8s.yaml with image ${IMAGE_NAME}:${IMAGE_TAG}"

                powershell """
                    (Get-Content k8s.yaml) -replace 'image:\\s*${IMAGE_NAME}:.*', 'image: ${IMAGE_NAME}:${IMAGE_TAG}' | Set-Content k8s.yaml
                """
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo 'Deploying application to Minikube...'

                bat """
                    kubectl apply -f k8s.yaml
                """
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
            bat """
                docker system prune -f
            """
        }
    }
}
