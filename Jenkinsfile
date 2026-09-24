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

    stage('Test Docker Hub Credential') {
        steps {
            echo 'Testing Docker Hub credential...'

            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-deepcreds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )
            ]) {
                bat '''
                    echo Username: %DOCKER_USERNAME%

                    if "%DOCKER_PASSWORD%"=="" (
                        echo PASSWORD IS EMPTY
                        exit /b 1
                    ) else (
                        echo PASSWORD RECEIVED
                    )
                '''
            }
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
                bat '''
                    $env:DOCKER_PASSWORD | & "$env:DOCKER_EXE" login -u "$env:DOCKER_USERNAME" --password-stdin

                    if ($LASTEXITCODE -ne 0) {
                        exit $LASTEXITCODE
                    }
                '''
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
            echo "Updating Kubernetes image tag..."

            powershell """
                if (!(Test-Path "k8s.yaml")) {
                    Write-Error "k8s.yaml file not found!"
                    exit 1
                }

                (Get-Content "k8s.yaml") -replace 'image:\\s*${IMAGE_NAME}:.*', 'image: ${IMAGE_NAME}:${IMAGE_TAG}' | Set-Content "k8s.yaml"
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
        echo "========================================"
        echo "Pipeline completed successfully!"
        echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        echo "========================================"
    }

    failure {
        echo "========================================"
        echo "Pipeline FAILED!"
        echo "Check the Console Output."
        echo "========================================"
    }

    always {
        bat """
            "${DOCKER_EXE}" logout
        """
    }
}
}
