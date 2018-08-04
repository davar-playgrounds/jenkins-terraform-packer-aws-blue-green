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
                    echo "APP_NAME = ${APP_NAME}"
                    echo "VERSION = ${VERSION}"
                '''
            }
        }
    }
}
