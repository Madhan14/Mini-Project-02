pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')   // Jenkins DockerHub creds ID
        DOCKER_IMAGE = "madhan14/trend"                          // Your DockerHub repo
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Madhan14/Mini-Project-02.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE:latest .'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'ap-south-1') {
                    sh '''
                        # Create a temporary kubeconfig each run
                        KCFG=$(mktemp)
                        aws eks update-kubeconfig \
                          --region ap-south-1 \
                          --name trend-eks-cluster \
                          --kubeconfig $KCFG
                        
                        export KUBECONFIG=$KCFG

                        # Verify connection
                        kubectl get nodes

                        # Rolling update to latest image
                        kubectl set image deployment/trend-deployment trend-app=$DOCKER_IMAGE:latest --record
                        kubectl rollout status deployment/trend-deployment --timeout=120s
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
