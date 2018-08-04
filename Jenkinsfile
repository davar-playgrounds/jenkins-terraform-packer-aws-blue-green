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
packer build -var 'app_name='"${APP_NAME}" -var 'version='"${VERSION}" build-ami.json'''
//                sh 'packer build -force ${WORKSPACE}/config/packer/build-ami.json 2>&1 | tee output.txt'
//                sh 'AMI_ID=$(tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')'
//                sh 'aws ssm put-parameter --name "/simulcast/ami/base_ami_id" --value "${AMI_ID}" --type String --region us-east-1 --overwrite'
           }
       }

        stage('Deploy to E2E') {
            steps {
                sh 'echo "Deploying to E2E"'
                sh '''cd ${WORKSPACE}/config/terraform
pwd
ls -altr
rm -f terraform.tfvars
echo "app_name = "\"${APP_NAME}\""" >>terraform.tfvars
echo "version = "\"${VERSION}\""" >>terraform.tfvars
cat terraform.tfvars
terraform init
terraform apply'''
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
