@Library('agv-shared-libraries') _

pipeline {
    agent any

    environment {
        PROJECT = 'agv-alr'
    }

    parameters {
        choice(name: 'ENV', choices: ['tst'], description: 'Select the deployment environment')
        booleanParam(name: 'BUILD', defaultValue: false, description: 'Select this stage to build an image')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Select this stage to deploy into minikube cluster')
    }
    
    stages {
        stage('Init') {
            steps {
                script {
                    checkAndInitMinikube()
                }
            }
        }
        stage('Build') {
            when { expression { return params.BUILD } }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: '68bcf519-10e7-4080-a3c7-d2165a00477f', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                            sudo podman login --tls-verify=false -u ${USERNAME} -p ${PASSWORD} 192.168.12.16:7005
                            sudo podman build --rm --no-cache -t ${project} .
                            sudo podman push --tls-verify=false ${project} 192.168.12.16:7005/agv-automated-guided-vehicles/${project}
                            sudo podman rmi ${project}
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            when { expression { return params.DEPLOY } }
            steps {
                script {
                    sh """
                        kubectl delete -f configmap.yaml -n tst --context=minikube --ignore-not-found
                        kubectl delete -f job.yaml -n tst --context=minikube --ignore-not-found
                        kubectl delete -f deployment.yaml -n tst --context=minikube --ignore-not-found
                        kubectl delete -f service.yaml -n tst --context=minikube --ignore-not-found
                        
                        kubectl apply -f configmap.yaml -n tst --context=minikube
                        kubectl apply -f job.yaml -n tst --context=minikube
                        kubectl apply -f deployment.yaml -n tst --context=minikube
                        kubectl apply -f service.yaml -n tst --context=minikube
                    """
                }
            }
        }
    }
}
