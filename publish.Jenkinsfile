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

def failedStage = ''
pipeline {

    agent {
        node {
            label NODE_LABEL
        }
    }

    environment {
        DEVELOPER_NAME = getDeveloperName()
        TEAM_NAME = "$DEVELOPER_NAME - Bravo"
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

        stage('Init Drop'){
            steps{
                sh "${bob} init-drop"
                archiveArtifacts 'artifact.properties'
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

        stage('Push image to drop'){
            steps{
                sh "${bob} push-image-drop"
            }
        }

        stage('Push Helm Chart to drop') {
            steps {
                withCredentials([string(credentialsId: 'HELM_REPO_API_TOKEN', variable: 'HELM_REPO_API_TOKEN')]) {
                    sh "${bob} push-helm-drop"
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


def getDeveloperName() {
    developerName = env.GERRIT_CHANGE_OWNER_NAME.split(" ")[0]
    echo "INFO: developerName: $developerName"
    return developerName
}
