pipeline {
    agent any

    environment {
        GOCACHE = "${WORKSPACE}/.gocache"
    }

    stages {
        stage('Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile.ci'
                    additionalBuildArgs '--build-arg=GOCACHE=/go/cache'
                    args '-u root -v /var/lib/jenkins/.gocache:/go/cache -v /var/lib/jenkins/.gomod:/go/pkg'
                }
            }
            steps {
                sh 'mkdir -p $GOCACHE'
                sh 'go test ./... -v'
            }
        }

        stage("Lint & Analysis") {
            agent {
                docker {
                    image 'golangci/golangci-lint:v1.59.0-alpine'
                }
                // dockerfile {
                //     filename 'Dockerfile.ci'
                //     args '-u root -v /var/lib/jenkins/.gocache:/go/cache -v /var/lib/jenkins/.gomod:/go/pkg'
                // }
            }
            steps {
                // sh 'mkdir -p $GOCACHE'
                sh 'golangci-lint run ./...'
                // optional: add another analyzer
                // sh 'staticcheck ./... || true'
            }
        }

        stage ("Build") {
            steps {
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
        }

        stage ("Deploy") {
            steps {
                echo "Deployment steps go here"
            }
        }
    }
}
