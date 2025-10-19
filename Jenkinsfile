pipeline {
    agent any

    tools {
        maven 'Maven-3.9.8'
    }

    environment {
        DOCKERHUB_USERNAME = "sehaj07" // Your Docker Hub username
        IMAGE_NAME         = "${env.DOCKERHUB_USERNAME}/portfolio-pipeline"
        IMAGE_TAG          = "build-${env.BUILD_NUMBER}"
    }

    stages {
        
        // --- STAGE 1: CHECKOUT ---
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // --- STAGE 2: TEST ---
        stage('Test') {
            steps {
                bat "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        // --- STAGE 3: BUILD & PUSH DOCKER IMAGE ---
        stage('Build & Push Docker Image') {
            steps {
                script {
                    bat "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                }
                
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                                                  passwordVariable: 'DOCKER_PASS', 
                                                  usernameVariable: 'DOCKER_USER')]) {
                    script {
                        bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        bat "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        bat "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
            post {
                always {
                    bat "docker logout"
                }
            }
        }

        // --- STAGE 4: DEPLOY TO LOCAL DOCKER ---
        stage('Deploy to Local Docker') {
            steps {
                script {
                    def containerName = 'portfolio-app-live'
                    
                    echo "Deploying ${IMAGE_NAME}:latest to local Docker..."
                    
                    bat "docker stop ${containerName} || true"
                    bat "docker rm ${containerName} || true"
                    bat "docker pull ${IMAGE_NAME}:latest"
                    bat "docker run -d -p 8090:8090 --name ${containerName} --rm ${IMAGE_NAME}:latest"
                    
                    echo "Deployment complete. Application should be running at http://localhost:8090"
                }
            }
        }
        
    } // End of stages
} // End of pipeline