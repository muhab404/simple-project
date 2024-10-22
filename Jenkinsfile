pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        EC2_SSH_KEY = credentials('ec2-ssh-key')  // Use the SSH key added to Jenkins credentials
    }

    stages {
        stage('Docker Login') {
            steps {
                // Add --password-stdin to run docker login command non-interactively
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build the Docker image locally
                sh 'docker build -t muhab404/comingsoon-page .'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    sh 'docker push muhab404/comingsoon-page'
                }
            }
        }

        stage('Run Ansible Playbook on EC2') {
            steps {
                // Run Ansible playbook on the remote EC2 instance
                script {
                    sh """
                    ansible-playbook -i inventory.ini --private-key \$EC2_SSH_KEY ansible-playbook.yml
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after the pipeline completes
            cleanWs()
        }
    }
}
