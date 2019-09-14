pipeline {
  agent {
    label 'ubuntu_docker_label'
  }
  tools {
    go "Go 1.11"
  }
  options {
    checkoutToSubdirectory('src/github.com/github.com/bukhavtsov/toolkit-log-service')
  }
  environment {
    GOPATH = "$WORKSPACE"
    DIRECTORY = "src/github.com/bukhavtsov/toolkit-log-service"
  }
  stages {
    stage("Lint") {
      steps {
        sh "cd $DIRECTORY && make fmt && git diff --exit-code > /dev/null"
      }
    }
    stage("Test") {
      steps {
        sh "cd $DIRECTORY && make test"
      }
    }
    stage("Build") {
      steps {
        withDockerRegistry([credentialsId: "<insert-the-creds-id>", url: ""]) {
          sh "cd $DIRECTORY && make docker push"
        }
      }
    }
    stage("Push") {
      when {
        branch "master"
      }
      steps {
        withDockerRegistry([credentialsId: "<insert-the-creds-id>", url: ""]) {
          sh "cd $DIRECTORY && make push IMAGE_VERSION=latest"
        }
      }
    }
  }
}

