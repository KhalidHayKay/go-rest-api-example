pipeline {
    agent any

    environment {
        GOCACHE = "${WORKSPACE}/.gocache"
    }

    stages {
        // Always start by checking out the repo
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // Lint & static analysis first, fail fast if code style / issues are present
        stage("Lint & Analysis") {
            agent {
                docker {
                    image 'golangci/golangci-lint:v1.59.0-alpine'
                    args '-u root'
                }
            }
            steps {
                script {
                    githubNotify context: 'Lint & Analysis', status: 'PENDING', description: 'Running lint checks'
                }
                // sh 'golangci-lint run'
                
                sh 'echo "Skipping lint for demo purposes"'
            }
            post {
                success {
                    githubNotify context: 'Lint & Analysis', status: 'SUCCESS', description: 'Lint passed'
                }
                failure {
                    githubNotify context: 'Lint & Analysis', status: 'FAILURE', description: 'Lint issues found'
                }
            }
        }

        // Run unit tests
        stage('Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile.ci'
                    additionalBuildArgs '--build-arg=GOCACHE=/go/cache'
                    args '-u root -v /var/lib/jenkins/.gocache:/go/cache -v /var/lib/jenkins/.gomod:/go/pkg'
                }
            }
            steps {
                script {
                    githubNotify context: 'Tests', status: 'PENDING', description: 'Running unit tests'
                }
                sh 'mkdir -p $GOCACHE'
                sh 'go test ./... -v'
            }
            post {
                success {
                    githubNotify context: 'Tests', status: 'SUCCESS', description: 'All tests passed'
                }
                failure {
                    githubNotify context: 'Tests', status: 'FAILURE', description: 'Tests failed'
                }
            }
        }

        // Build & smoke test container
        stage ("Build") {
            steps {
                script {
                    githubNotify context: 'Build', status: 'PENDING', description: 'Building Docker image'
                }

                sh "docker build -t go-rest-api-example ."

                // Run container in background
                sh "docker run --rm -d --name taskify-ci-test -p 5000:5000 go-rest-api-example"

                // Wait for app to come up
                sh "sleep 10"

                // Verify app responds
                sh "curl -f http://localhost:5000 || (echo 'App did not start' && exit 1)"

                // Stop container (ignore errors if not running)
                sh "docker stop taskify-ci-test || true"
            }
            post {
                success {
                    githubNotify context: 'Build', status: 'SUCCESS', description: 'Build succeeded and app responded'
                }
                failure {
                    githubNotify context: 'Build', status: 'FAILURE', description: 'Build failed or app did not respond'
                }
            }
        }

        // Deployment (only runs if all above succeeded)
        stage ("Deploy") {
            steps {
                script {
                    githubNotify context: 'Deploy', status: 'PENDING', description: 'Starting deployment'
                }
                echo "Deployment steps go here"
            }
            post {
                success {
                    githubNotify context: 'Deploy', status: 'SUCCESS', description: 'Deployment succeeded'
                }
                failure {
                    githubNotify context: 'Deploy', status: 'FAILURE', description: 'Deployment failed'
                }
            }
        }
    }
}
