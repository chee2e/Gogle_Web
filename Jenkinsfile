pipeline {
    agent  {
        label 'dind-agent'
    }
    stages {
        
        stage('Start') {
            agent any
            steps {
                slackSend (channel: '#jenkins', color: '#FFFF00', message: "새로운 이미지 빌드를 시작합니다. '빌드 넘버:${env.BUILD_NUMBER}' (http://jenkins.korea-festival.shop/job/kf-pipeline/)")
            }
        }

        stage('Build image') {
            steps {
                script {
                    app = docker.build("class-mino-01/kfimg")
                }
            }
        }
        
        stage("Push image to AR") {
            steps {
                script {
                    docker.withRegistry('https://asia.gcr.io', 'gcr:class-mino-01') {
                        app.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

        stage('K8S Manifest Update') {

            steps {

                git credentialsId: 'XOXOT',
                    url: 'https://github.com/XOXOT/argoCD_yaml.git',
                    branch: 'main'

                sh "sed -i 's/kfimg:.*\$/kfimg:${env.BUILD_NUMBER}/g' kf-deployment/deployment.yaml"
                sh "git add kf-deployment/deployment.yaml"
                sh "git commit -m '[UPDATE] kfimg ${env.BUILD_NUMBER} image versioning'"
                withCredentials([gitUsernamePassword(credentialsId: 'XOXOT')]) {
                    sh "git push -u origin main"
                }
            }
            post {
                    failure {
                    echo 'Update failure !'
                    }
                    success {
                    echo 'Update success !'
                    }
            }
        }

    }
    
    post {
        success {
            slackSend (channel: '#jenkins', color: '#00FF00', message: "빌드가 성공적으로 완료 되었습니다. 잠시 후 ArgoCD에서 자동으로 배포될 예정입니다. : Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (http://jenkins.korea-festival.shop/job/kf-pipeline/)")
        }
        failure {
            slackSend (channel: '#jenkins', color: '#FF0000', message: "빌드가 실패하였습니다. 링크에 접속하여 확인 부탁드립니다. : Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (http://jenkins.korea-festival.shop/job/kf-pipeline/)")
        }
    }

}
