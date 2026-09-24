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

    stage('Login to Docker Hub') {
        steps {
            echo 'Logging in to Docker Hub...'

            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-deepcreds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )
            ]) {
                bat """
                    echo %DOCKER_PASSWORD% | "${DOCKER_EXE}" login -u "%DOCKER_USERNAME%" --password-stdin
                """
            }
        }
    }

    stage('Push to Docker Hub') {
        steps {
            echo "Pushing ${IMAGE_NAME}:${IMAGE_TAG} to Docker Hub..."

            bat """
                "${DOCKER_EXE}" push ${IMAGE_NAME}:${IMAGE_TAG}
                "${DOCKER_EXE}" push ${IMAGE_NAME}:latest
            """
        }
    }

    stage('Update k8s.yaml Image Tag') {
        steps {
            echo "Updating Kubernetes image to ${IMAGE_NAME}:${IMAGE_TAG}..."

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
        echo "Deployment successful: ${IMAGE_NAME}:${IMAGE_TAG}"
    }

    failure {
        echo "Pipeline failed - check Console Output."
    }

    always {
        bat """
            "${DOCKER_EXE}" logout
            "${DOCKER_EXE}" system prune -f
        """
    }
}
}
