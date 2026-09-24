pipeline {
agent any
environment {
    IMAGE_NAME = "deepu09567/dockerwebsite"
    IMAGE_TAG = "${BUILD_NUMBER}"
    DOCKER_EXE = "C:\\Users\\Ankit\\AppData\\Local\\Programs\\DockerDesktop\\resources\\bin\\docker.exe"
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
                "${DOCKER_EXE}" build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                "${DOCKER_EXE}" tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
            """
        }
    }

    stage('Push to Docker Hub') {
        steps {
            echo 'Logging in to Docker Hub...'

            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )
            ]) {
                bat """
                    "${DOCKER_EXE}" login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%"
                    "${DOCKER_EXE}" push ${IMAGE_NAME}:${IMAGE_TAG}
                    "${DOCKER_EXE}" push ${IMAGE_NAME}:latest
                    "${DOCKER_EXE}" logout
                """
            }
        }
    }

    stage('Update k8s.yaml Image Tag') {
        steps {
            echo 'Updating Kubernetes image tag...'

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
        echo "Deployed ${IMAGE_NAME}:${IMAGE_TAG} successfully."
    }

    failure {
        echo "Pipeline failed - check console output."
    }

    always {
        bat """
            "${DOCKER_EXE}" system prune -f
        """
    }
}
}
