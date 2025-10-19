pipeline {
    // 1. Specify the Jenkins agent
    // 'agent any' means Jenkins can run this on any available machine.
    agent any

    // 2. Define tools to use
    // This tells Jenkins to use the "Maven-3.9.8" tool we configured in 'Manage Jenkins -> Tools'.
    tools {
        maven 'Maven-3.9.8'
    }

    // 3. Define environment variables for the pipeline
    environment {
        // *** YOU MUST CHANGE THIS ***
        // Replace 'your-dockerhub-username' with your actual Docker Hub username
        DOCKERHUB_USERNAME = "sehaj07" 
        IMAGE_NAME         = "${env.DOCKERHUB_USERNAME}/portfolio-pipeline"
        IMAGE_TAG          = "build-${env.BUILD_NUMBER}" // Tags the image with the build number (e.g., build-1, build-2)
    }

    // 4. Define the stages of the pipeline
    stages {
        
        // --- STAGE 1: CHECKOUT ---
        // Pulls the latest code from your GitHub repository.
        stage('Checkout') {
            steps {
                // This 'checkout scm' step is automatically provided by Jenkins
                // when we link the job to our Git repo.
                checkout scm 
            }
        }

        // --- STAGE 2: BUILD ---
        // Compiles the Java code and packages it into a .jar file.
        stage('Build') {
            steps {
                // On Windows, Jenkins uses 'bat' (Batch). On Linux/macOS, it would be 'sh' (Shell).
                bat "mvn clean package -DskipTests"
            }
            // Save the compiled .jar file as an "artifact" for this build.
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        // --- STAGE 3: TEST ---
        // Runs the unit tests (we don't have any, but this is a best practice).
        stage('Test') {
            steps {
                bat "mvn test"
            }
            // Save the test results.
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        // --- STAGE 4: BUILD DOCKER IMAGE ---
        // Uses the Dockerfile to build a new image.
        stage('Build Docker Image') {
            steps {
                script {
                    // This command uses the Docker plugin.
                    // It builds the image and tags it twice:
                    // 1. With the unique build tag (e.g., 'your-name/portfolio-pipeline:build-5')
                    // 2. With the 'latest' tag
                    bat "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        // --- STAGE 5: PUSH TO DOCKER HUB ---
        // Pushes the new image to your Docker Hub repository.
        stage('Push to Docker Hub') {
            steps {
                // This 'withCredentials' block securely injects the 'dockerhub-creds'
                // we set up in Step 6. It maps them to variables.
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                                                  passwordVariable: 'DOCKER_PASS', 
                                                  usernameVariable: 'DOCKER_USER')]) {
                    script {
                        // 1. Log in to Docker Hub using the injected credentials
                        bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        
                        // 2. Push the image with the unique build tag
                        bat "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        
                        // 3. Push the 'latest' tag
                        bat "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
            // Always log out of Docker Hub when done
            post {
                always {
                    bat "docker logout"
                }
            }
        }
    }
}