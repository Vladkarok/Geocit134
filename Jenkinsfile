pipeline {

    agent {
        label 'nexus'
    }

    environment {
        db_user        = credentials('db_user')
        db_password    = credentials('db_password')
        db_name        = credentials('db_name')
        email_login    = credentials('email_login')
        email_password = credentials('email_password')
        nexus_oss_url  = "35.247.90.117:8081"
    }

    triggers {
        githubPush()
    }

    tools {
        maven "3.6.3"
    }

    stages {
    
        stage ('Clean WS') {
            steps {
                // clean current workspace directory
                cleanWs()

            }
        }

        stage ('Clone Geo Citizen project') {
            steps {             
                git branch: 'main', credentialsId: 'github-ssh', url: 'git@github.com:Vladkarok/Geocit134.git'

            }
        }        

        stage('Project fixing / configuration') {
            steps {
                // fix project
                script{
                    sh '''#!/bin/bash
                    #################################################
                    ### Set the environment variables
                    #################################################
                    
                    s_db_user=${db_user}
                    s_db_password=${db_password}
                    s_db_name=${db_name}
                    s_email_login=${email_login}
                    s_email_password=${email_password}
                    s_serverip="geocitizen.vladkarok.ml"
                    s_databaseip="dbgeo.vladkarok.ml"

                    ##################Adjusting_application.properties###############################
                    sed -i -E \\
                                "s/(http:\\/\\/localhost:8080)/https:\\/\\/${s_serverip}:80/g; \\

                                s/(postgresql:\\/\\/localhost)/postgresql:\\/\\/${s_databaseip}/g;
                                s/(35.204.28.238)/${s_databaseip}/g;
                                s/(db.username=postgres)/db.username=${s_db_user}/g;
                                s/(db.password=postgres)/db.password=${s_db_password}/g;
                                s/(username=postgres)/username=${s_db_user}/g;
                                s/(password=postgres)/password=${s_db_password}/g;
                                s/(ss_demo_1)$/${s_db_name}/g;

                                s/(email.username=ssgeocitizen@gmail.com)/email.username=${s_email_login}/g;
                                s/(email.password=softserve)/email.password=${s_email_password}/g;" src/main/resources/application.properties
                    
                    ##################Repair index.html favicon###############################
                    sed -i "s/\\/src\\/assets/\\.\\/static/g" src/main/webapp/index.html

                    ##################Repair js bundles###############################
                    find ./src/main/webapp/static/js/ -type f -exec sed -i "s/localhost:8080/${s_serverip}:80/g" {} +
                    find ./src/main/webapp/static/js/ -type f -exec sed -i "s/http:\\/\\/${s_serverip}:80/https:\\/\\/${s_serverip}:80/g" {} +

                    '''
                }
                
            }
        }

        stage('Build Geo Citizen with Maven') {
            steps {
                script {
                    try {
                        notifyBuild("STARTED")
                        sh("mvn clean install")
                    } catch (e) {
                        currentBuild.result = "FAILED"
                        jiraComment body: "Job \"${env.JOB_NAME}\" FAILED! ${env.BUILD_URL}", issueKey: 'CDA-21'
                        throw e
                    } finally {
                        notifyBuild(currentBuild.result)
                    }
                }
            }
        }        

        stage('Uploading to Nexus') {
            steps{
                script{
                    try {
                        def mavenPom = readMavenPom file: 'pom.xml'
                        def nexusRepoName = mavenPom.version.endsWith('-SNAPSHOT') ? 'maven-snapshots' : 'maven-releases'
                        nexusArtifactUploader artifacts: [
                            [
                                artifactId: 'geo-citizen', 
                                classifier: '', 
                                file: "target/citizen.war", 
                                type: 'war'
                            ]
                        ], 
                        credentialsId: 'geo-nexus-user', 
                        groupId: 'com.softserveinc', 
                        nexusUrl: "${nexus_oss_url}", 
                        nexusVersion: 'nexus3', 
                        protocol: 'http', 
                        repository: nexusRepoName, 
                        version: "${mavenPom.version}"
                    } catch (e) {
                        currentBuild.result = "FAILED"
                        jiraComment body: "Job \"${env.JOB_NAME}\" FAILED! ${env.BUILD_URL}", issueKey: 'CDA-21'
                        throw e
                    } finally {
                        notifyBuild(currentBuild.result)
                    }
                }

            }
        }
    }
}
def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus =  buildStatus ?: 'SUCCESSFUL'

    // Default values
    def colorName = 'RED'
    def colorCode = '#FF0000'
    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL}) (${currentBuild.durationString})"

    // Override default values based on build status
    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESSFUL') {
        color = 'GREEN'
        colorCode = '#00FF00'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }

    // Send notifications
    slackSend (color: colorCode, message: summary)
}

            
