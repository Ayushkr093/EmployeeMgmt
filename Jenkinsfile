pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ayushkr08'
        APP_IMAGE = 'my_php_app'
        GIT_BRANCH = 'main'
        GIT_REPO_URL = 'https://github.com/Ayushkr093/EmployeeMgmt.git'
        COMPOSE_FILE = 'docker-compose.yml' // Explicit compose file
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
                script {
                    // Add build args if needed
                    sh """
                        docker build -t ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH} .
                        docker tag ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH} ${DOCKER_REGISTRY}/${APP_IMAGE}:latest
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH}
                    docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:latest
                """
            }
        }

        stage('Run Locally') {
            steps {
                sh """
                    docker-compose -f ${COMPOSE_FILE} down --remove-orphans || true
                    docker-compose -f ${COMPOSE_FILE} up -d --build --force-recreate
                    sleep 10 # Wait for containers to initialize
                    docker-compose -f ${COMPOSE_FILE} ps # Show container status
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Add health check
                    sh 'curl -I http://localhost:3003 || true'
                }
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
