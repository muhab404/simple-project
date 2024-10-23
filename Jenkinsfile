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

        // stage('Run Ansible Playbook on EC2') {
        //     steps {
        //         // Run Ansible playbook on the remote EC2 instance
        //         script {
        //             // Create a temporary file for the private key
        //             // def sshKeyFile = "${env.WORKSPACE}/key.pem"
        //             // writeFile file: sshKeyFile, text: EC2_SSH_KEY.getPrivateKey()
        //             // sh "chmod 400 ${sshKeyFile}"


        //             sh """
        //             chmod 400 key.pem
        //             ls -al
        //             pwd
        //             ansible-playbook -i inventory.ini --private-key \$EC2_SSH_KEY ansible-playbook.yml
        //             """
        //         }
        //     }
        // }
        stage("Execute Ansible") {
            steps {
                ansiblePlaybook credentialsId: 'ssh',
                                 disableHostKeyChecking: true,
                                 installation: 'Ansible',
                                 inventory: 'inventory.ini',
                                 playbook: 'ansible-playbook.yml'
            }    
        }    

    }

    post {
        success {
            emailext(
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Job '${env.JOB_NAME}' has succeeded. Check console output at ${env.RUN_DISPLAY_URL}",
                to: 'muhabseif@gmail.com', 'ahmadbadawy291@gmail.com',
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
            )
        }
        failure {
            emailext(
                subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Job '${env.JOB_NAME}' has failed. Check console output at ${env.RUN_DISPLAY_URL}",
                to: 'muhabseif@gmail.com',
                recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
            )
        }

        always {
            // Clean up workspace after the pipeline completes
            cleanWs()
        }
    }
}
