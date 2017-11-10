pipeline {
  agent {
    node {
      label 'dckubt16s1'
    }
    
  }
  stages {
    stage('') {
      steps {
        sh '''pwd
cd amd64
docker build --no-cache .
docker images'''
      }
    }
  }
}