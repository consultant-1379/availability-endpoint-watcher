#!/usr/bin/env groovy
def bob = "docker run --rm " +
        '--user $(id -u):$(id -g) ' +
        '--workdir "`pwd`" ' +
        '--env RELEASE=${RELEASE} ' +
        '--env HOME=${HOME} ' +
        '--env HELM_REPO_API_TOKEN=${HELM_REPO_API_TOKEN} ' +
        "-w `pwd` " +
        "-v \"`pwd`:`pwd`\" " +
        '-v ${HOME}:${HOME} ' +
        '-v /etc/passwd:/etc/passwd:ro ' +
        "-v /var/run/docker.sock:/var/run/docker.sock " +
        "armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:1.7.0-31"

pipeline {

    agent {
        node {
            label NODE_LABEL
        }
    }

    stages {

        stage('PrintHostIP') {
             steps {
                 sh '''#/bin/bash
                  echo "slave ip : $(hostname -i)"
                  sudo chmod 666 /var/run/docker.sock
                  '''
             }
         }

        stage('Clean workspace'){
            steps {
                sh "${bob} clean"
            }

        }

        stage('Init Review'){
            steps{
                sh "${bob} init-review"
            }

        }

        stage('Lint') {
            steps {
                /*sh "${bob} lint"
                sh "${bob} lint-dockerfile"
                archiveArtifacts '*dockerfilelint.log'
                 */
                echo "Enable in future."
            }
        }

        stage('Build Source Code') {
            steps {
                sh "${bob} build"
            }
        }

        stage('Build Image') {
            steps {
                sh "${bob} build-image"
            }
        }

        stage('Push image to ci-internal') {
            steps {
                sh "${bob} push-image-internal"
            }
        }

        stage('Push Helm Chart to ci-internal') {
            steps {
                withCredentials([string(credentialsId: 'HELM_REPO_API_TOKEN', variable: 'HELM_REPO_API_TOKEN')]) {
                    sh "${bob} push-helm-internal"
                }
            }
        }


    }
    post {
        always{
            sh "${bob} clean"
        }
    }
}



