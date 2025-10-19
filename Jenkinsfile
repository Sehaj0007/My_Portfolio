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
        // Just compile and run tests on the Jenkins agent.
        // This is faster and gives quick feedback.
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
        // The Dockerfile will now do the 'mvn package' and build the image.
        stage('Build & Push Docker Image') {
            steps {
                script {
                    // Build the image
                    bat "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                }
                
                // Log in and push the image
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
            // Always log out
            post {
                always {
                    bat "docker logout"
                }
            }
        }
    }
}