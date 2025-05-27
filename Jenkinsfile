pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ayushkr08'
        APP_IMAGE = 'my_php_app'
        GIT_BRANCH = 'main'
        GIT_REPO_URL = 'https://github.com/Ayushkr093/EmployeeMgmt.git'
    }

    stages {
        stage('Checkout Code') {
            steps {
                cleanWs()
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_CREDENTIALS',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKER_REGISTRY/$APP_IMAGE:$GIT_BRANCH .
                    docker tag $DOCKER_REGISTRY/$APP_IMAGE:$GIT_BRANCH $DOCKER_REGISTRY/$APP_IMAGE:latest
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    docker push $DOCKER_REGISTRY/$APP_IMAGE:$GIT_BRANCH
                    docker push $DOCKER_REGISTRY/$APP_IMAGE:latest
                '''
            }
        }

        stage('Run Locally') {
            steps {
                sh '''
                    docker-compose down --remove-orphans || true
                    docker-compose up -d --build --force-recreate
                '''
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning workspace'
            cleanWs()
        }
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build or deployment failed!'
        }
    }
}
