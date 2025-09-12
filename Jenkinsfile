pipeline {
    agent any

    stages {
        stage('Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile.ci'
                    label 'latest'
                }
            }
            steps {
                sh 'go test ./...'
            }
        }

        stage("Lint & Analysis") {
            agent {
                dockerfile {
                    filename 'Dockerfile.ci'
                    label 'latest'
                }
            }
            steps {
                sh 'golangci-lint run ./...'
            }
        }

        stage ("Build") {
            steps {
                sh "docker build -t go-rest-api-example ."

                // Run container with a name
                sh "docker run --rm -d --name taskify-ci-test -p 5000:5000 go-rest-api-example"

                // Wait for it to come up
                sh "sleep 10"

                // Verify app responds
                sh "curl -f http://localhost:5000 || (echo 'App did not start' && exit 1)"

                // Stop container
                sh "docker stop taskify-ci-test"
            }
        }

        stage ("Deploy") {
            steps {
                echo "Deployment steps go here"
            }
        }
    }
}
