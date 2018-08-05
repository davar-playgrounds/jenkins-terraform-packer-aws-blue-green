pipeline {
    agent { label 'master' }
    environment {
        VERSION = "1.0.${BUILD_NUMBER}"
        APP_NAME = "demo_app"
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }

        stage ('Build Artifact') {
            steps {
//                sh 'mvn -Dmaven.test.failure.ignore=true install'
                sh 'echo "Building artifact."'
            }
        }

        stage ('Test') {
            steps {
                sh 'echo "This is where we would add the tests"'
            }
        }

        stage('Build AMI') {
            steps {
                sh 'echo "Building AMI ..."'
                sh 'rm -f output.txt'
                sh 'echo "${APP_NAME} ${VERSION}"'
                sh '''cd ${WORKSPACE}/config/packer
packer build -var 'app_name='"${APP_NAME}" -var 'version='"${VERSION}" build-ami.json 2>&1 | tee output.txt
AMI_ID=$(tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
aws ssm put-parameter --name "/${APP_NAME}/ami/${VERSION}" --value "${AMI_ID}" --type String --region us-east-1 --overwrite'''
           }
       }

        stage('Deploy to E2E') {
            steps {
                sh 'echo "Deploying to E2E"'
                sh '''cd ${WORKSPACE}/config/terraform
pwd
ls -altr
AMI=$(aws ssm get-parameters --names "/${APP_NAME}/ami/${VERSION}" --region us-east-1 | jq -r '.Parameters[].Value')
rm -f terraform.tfvars
echo 'app_name = "'${APP_NAME}'"' >>terraform.tfvars
echo 'version = "'${VERSION}'"' >>terraform.tfvars
echo 'ami_name = "'${AMI}'"' >>terraform.tfvars
cat terraform.tfvars
terraform init
terraform apply -auto-approve'''
           }
       }

        stage('User Input') {
            input {
                message "Deploy to Production?"
                ok "Yes Deploy"
                submitter "yes"
                parameters {
                    string(name: 'DEPLOY', defaultValue: '', description: 'Type "yes" to deploy to Production environment.')
                }
            }
            steps {
                echo "Deploying to Production because you typed: ${DEPLOY}"
            }
        }

    }
    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}
