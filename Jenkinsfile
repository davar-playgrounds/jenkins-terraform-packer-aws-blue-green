pipeline {
    agent { label 'java' }
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
            agent { label 'terraform' }
            steps {
                sh 'echo "Building AMI ..."'
                sh 'rm -f output.txt'
                sh 'packer build -force ${WORKSPACE}/config/packer/build-ami.json 2>&1 | tee output.txt'
//                sh 'AMI_ID=$(tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')'
//                sh 'aws ssm put-parameter --name "/simulcast/ami/base_ami_id" --value "${AMI_ID}" --type String --region us-east-1 --overwrite'
           }
       }

        stage('Deploy to E2E') {
            agent { label 'terraform' }
            steps {
                sh 'echo "Deploying to E2E"'
                sh '''cd ${WORKSPACE}/config/terraform
pwd
ls -altr
terraform init
terraform apply'''
           }
       }


    }
}