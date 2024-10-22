pipeline {
    agent any

    environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
        	EC2_SSH_KEY = credentials('ec2-ssh-key')  // Use the SSH key added to Jenkins credentials	}
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

        // stage('Run Tests') {
        //     steps {
        //         // Assuming you have tests (if not, you can remove this stage)
        //         sh 'docker run --rm muhab404/comingsoon-page ./run-tests.sh'
        //     }
        // }

        stage('Push Docker Image') {
            steps {
                script {
                    // Docker login
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    // Push the Docker image
                    sh 'docker push muhab404/comingsoon-page'
                }
            }
        }
        // stage('Build & push Dockerfile') {
        //     steps {
        //         sh """
        //         ansible-playbook ansible-playbook.yml
        //         """
        //     }
        // }
        stage('Run Ansible Playbook on EC2') {
            steps {
                // Run Ansible playbook on the remote EC2 instance
                script {
                    sh """
                    ansible-playbook -i '52.200.226.149,' -u ubuntu \
                    --private-key \$EC2_SSH_KEY ansible-playbook.yml
                    """
                }

    } 
}
