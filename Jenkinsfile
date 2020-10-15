pipeline {
    agent any
    environment {
        APP           = "image-autoheal"
        TAG           = "v${env.BUILD_NUMBER}"
        ECR           = "$DOCKER_REGISTRY/$APP:$TAG"
        IS_HEALTHY    = 'false'
     }
    options {
        buildDiscarder(logRotator(
                artifactDaysToKeepStr: '',
                artifactNumToKeepStr: '5',
                daysToKeepStr: '60',
                numToKeepStr: '10')
        )
        disableConcurrentBuilds()
        disableResume()
        timeout(time: 1, unit: 'HOURS')
    }

    stages {
        stage('Preparation'){
            steps{
                echo "######## Preparation ###################";
                script {
                    sshagent (credentials: ['bitbucket-key']) {
                        sh 'ls -laht'
                    }
                }

            }
        }

        stage('Build Image') {
            steps {
                script {
                    echo " ########## Build Docker Image ##########";
                    docker.withRegistry(ecr_url, ecr_region) {
                        echo "############ Build Docker Image ###############";
                        app = docker.build(ECR, "--force-rm --no-cache . ");
                    }
                }
            }
        }

        stage('Test'){
            options {
                timeout(time: 4, unit: 'MINUTES')
            }
            steps {
                script {
                    echo ("##########  ${APP} test Container ##########");
                    docker.withRegistry(ecr_url, ecr_region) {
                        echo "############ Build Docker Image ###############";
                        sh 'touch healthy.txt'
                        sh 'chmod +x healthy.txt'
                        sh 'chmod +x container-test.sh'
                        sh './container-test.sh $ECR'
                        IS_HEALTHY = readFile "healthy.txt"
                        echo "Healthy is '${IS_HEALTHY.trim()}'"
                        if ( IS_HEALTHY.trim() == "true" ) {
                            echo("########################  ${APP} container is Healthy #######################");
                        } else {
                            echo("####################### ${APP} container was Unhealthy ######################");
                        }
                    }
                }
            }       
        }

         stage('Push to ECR'){
            options {
                timeout(time: 4, unit: 'MINUTES')   // timeout on this stage
            }
            steps {
                script {
                    echo ("########## Publish to ECR ##########");
                    docker.withRegistry(ecr_url, ecr_region) {
                        if ( IS_HEALTHY.trim() == "true" ) {
                            echo ("######## Pushing to AWS ECR ${APP} repo with tag based on jenkins build number and a latest tag ########");
                            app.push();
                            app.push("latest");
                            echo " ######################### Publish to ECR complete!! ########################";
                        } else {
                            echo("########################### Container was unhealthy #######################");
                            echo (" ############### Container unhealthy nothing to push to ECR !!! #############");
                        }
                    }
                }
            }
         }

        stage('Clean Up'){
            steps{
                echo ("##########  ${APP} Job Complete !!! ########");
                sh 'docker image prune -fa';
                sh 'docker stop $(docker ps -a -q)';
                sh 'docker rm $(docker ps -a -q)';
            }
        }
    }
    post {
           success {
               bitbucketStatusNotify(buildState: 'IMAGE BUILD WAS SUCCESSFUL', repoSlug: '$APP-$TAG', commitId: env.GIT_COMMIT)
           }
           failure {
               bitbucketStatusNotify(buildState: 'IMAGE BUILD FAILED', repoSlug: '$APP-$TAG', commitId: env.GIT_COMMIT)
           }
      }
    }
