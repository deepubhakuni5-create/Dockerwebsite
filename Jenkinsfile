pipeline {
    agent any

    environment {
        DOCKER = 'C:\\Users\\Ankit\\AppData\\Local\\Programs\\DockerDesktop\\resources\\bin\\docker.exe'
    }

    stages {

        stage('Docker Version Test') {
            steps {
                echo 'Testing Docker...'

                bat '''
                    "%DOCKER%" version
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                echo 'Logging into Docker Hub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    bat '''
                        echo Docker username: %DOCKER_USER%
                        echo Docker password received from Jenkins.

                        echo %DOCKER_PASS% | "%DOCKER%" login -u "%DOCKER_USER%" --password-stdin

                        if %ERRORLEVEL% NEQ 0 (
                            echo.
                            echo ==============================
                            echo DOCKER HUB LOGIN FAILED
                            echo ==============================
                            exit /b 1
                        )

                        echo.
                        echo ==============================
                        echo DOCKER HUB LOGIN SUCCESSFUL
                        echo ==============================
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Docker Hub login test PASSED.'
        }

        failure {
            echo 'Docker Hub login test FAILED.'
        }
    }
}
