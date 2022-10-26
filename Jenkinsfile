pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
     }
      post {
        success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'BUILD' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'BUILD' stage")
          }
        }
   }
    stage ('Test') {
      steps {
        sh '''#!/bin/bash
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    
      post{
        always {
          junit 'test-reports/results.xml'
        }
      success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'TEST' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'TEST' stage")
        }
      }
    }
   
     stage('Init') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('D4_Terraform') {
                              sh 'terraform init' 
                            }
         }
    }
       post {
        success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'INIT' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'INIT' stage")
          }
        }
   }
      stage('Plan') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('D4_Terraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"' 
                            }
         }
    }
        post {
        success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'PLAN' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'PLAN' stage")
          }
        }
   }
      stage('Apply') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('D4_Terraform') {
                              sh 'terraform apply plan.tfplan' 
                            }
         }
    }
      post {
        success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'APPLY' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'APPLY' stage")
          }
        }  
   }
     stage('Destroy') {
       steps {
         withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
                          string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('D4_Terraform') {
                              sh 'terraform destroy -auto-approve -var="aws_access_key=${aws_access_key}" -var="aws_secret_key=${aws_secret_key}"'
                                                }
                            }
                      }
       post {
        success {
          slackSend (message: "FYI: ${BUILD_TAG} has SUCCESSFULLY completed its 'DESTROY' stage")
        }
        failure {
          slackSend (message: "ATTENTION: ${BUILD_TAG} has FAILED its 'DESTROY' stage")
          }
        }
        }
       }
 }
