pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ayushkr08'
        APP_IMAGE = 'php-mysql-app'
        GIT_BRANCH = 'main'
        GIT_REPO_URL = 'https://github.com/Ayushkr093/EmployeeMgmt.git'
    }

    stages {
        stage('Clone Repo') {
            steps {
                cleanWs()
                sh "git clone --branch ${GIT_BRANCH} --depth 1 ${GIT_REPO_URL} my-php-project"
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_CREDENTIALS',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                    docker build -t ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH} -t ${DOCKER_REGISTRY}/${APP_IMAGE}:latest my-php-project
                    docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH}
                    docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('my-php-project') {
                    sh '''
                    docker-compose pull || true
                    docker-compose down --remove-orphans
                    docker-compose up -d --build --force-recreate
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up...'
            sh 'docker system prune -f --volumes || true'
            cleanWs()
        }
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
