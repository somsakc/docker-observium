pipeline {
  agent {
    node {
      label 'dckubt16s1'
    }
    
  }
  stages {
    stage('verify envs') {
      parallel {
        stage('verify envs') {
          steps {
            sh 'set | grep -e BUILD -e JENKINS'
          }
        }
        stage('change working path') {
          steps {
            sh '''pwd
find . -ls
cd amd64'''
          }
        }
      }
    }
    stage('build docker') {
      steps {
        sh 'docker build --no-cache -t mbixtech/observium:jenkins-${BUILD_NUMBER} .'
      }
    }
    stage('verify docker') {
      steps {
        sh 'docker images'
      }
    }
  }
}