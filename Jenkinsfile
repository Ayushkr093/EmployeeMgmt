pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ayushkr08'
        APP_IMAGE = 'php-mysql-app'
        GIT_BRANCH = 'main'
        GIT_REPO_URL = 'https://github.com/Ayushkr093/EmployeeMgmt.git'
        
        // Build optimization variables
        DOCKER_BUILDKIT = '1'
        COMPOSE_DOCKER_CLI_BUILD = '1'
        BUILDKIT_INLINE_CACHE = '1'
    }

    stages {
        stage('Prepare Environment') {
            steps {
                cleanWs()
                script {
                    // Check if we can reuse existing clone
                    if (!fileExists('my-php-project')) {
                        echo '🔄 Cloning repository...'
                        sh "git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO_URL} my-php-project"
                    } else {
                        echo '🔄 Updating existing repository...'
                        dir('my-php-project') {
                            sh "git fetch --depth 1 origin ${GIT_BRANCH}"
                            sh "git reset --hard origin/${GIT_BRANCH}"
                        }
                    }
                }
            }
        }

        stage('Docker Operations') {
            parallel {
                stage('Build & Push Image') {
                    steps {
                        script {
                            withCredentials([usernamePassword(
                                credentialsId: 'DOCKER_CREDENTIALS',
                                usernameVariable: 'DOCKER_USERNAME',
                                passwordVariable: 'DOCKER_PASSWORD'
                            )]) {
                                sh '''
                                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                                docker build \
                                    --cache-from ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH} \
                                    -t ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH} \
                                    -t ${DOCKER_REGISTRY}/${APP_IMAGE}:latest \
                                    ./my-php-project
                                docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:${GIT_BRANCH}
                                docker push ${DOCKER_REGISTRY}/${APP_IMAGE}:latest
                                '''
                            }
                        }
                    }
                }

                stage('Prepare DB') {
                    steps {
                        dir('my-php-project') {
                            sh 'docker-compose pull || true'  // Pre-pull images if available
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                dir('my-php-project') {
                    sh '''
                    docker-compose down --remove-orphans
                    docker-compose up -d --build --force-recreate
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully!'
            slackSend(color: 'good', message: "Success: ${JOB_NAME} #${BUILD_NUMBER}")
        }
        failure {
            echo '❌ Deployment failed!'
            slackSend(color: 'danger', message: "Failed: ${JOB_NAME} #${BUILD_NUMBER}")
        }
        always {
            echo '🧹 Cleaning up...'
            sh '''
            docker system prune -f --volumes || true
            docker builder prune -af || true
            '''
            cleanWs()
        }
    }
}
