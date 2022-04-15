pipeline {
    agent { label '1' }

    environment {
        AWS_ACCESS_KEY_ID        = credentials('TERRAFORM_AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY    = credentials('TERRAFORM_AWS_SECRET_ACCESS_KEY')
    }

    tools {
        terraform 'Terraform'
    }

    stages {
        stage('Git checkout') {
            steps {
                git branch: 'terraform-aws', credentialsId: 'github-ssh', url: 'git@github.com:Vladkarok/Geocit134.git'
            }
        }
        stage("Terraform apply"){
            steps {
                script {
                    try {
                        notifyBuild("STARTED")
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform apply -auto-approve -no-color'
                    } catch (e) {
                        // If there was an exception thrown, the build failed
                        currentBuild.result = "FAILED"
                        jiraComment body: "Job \"${env.JOB_NAME}\" FAILED! ${env.BUILD_URL}", issueKey: 'CDA-21'
                        throw e
                    } finally {
                        // Success or failure, always send notifications
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