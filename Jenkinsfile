@Library('agv-shared-libraries') _

pipeline {
    agent any

    environment {
        PROJECT = 'agv-keycloak'
    }

    parameters {
        choice(name: 'ENV', choices: ['tst'], description: 'Select the deployment environment')
        booleanParam(name: 'BUILD', defaultValue: false, description: 'Select this stage to build an image')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Select this stage to deploy into minikube cluster')
        booleanParam(name: 'KEYCLOAK', defaultValue: false, description: 'Select this stage to expose keycloak')
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
                            sudo podman build --rm --no-cache -t ${env.PROJECT} .
                            sudo podman push --tls-verify=false ${env.PROJECT} 192.168.12.16:7005/agv-automated-guided-vehicles/${env.PROJECT}
                            sudo podman rmi ${env.PROJECT}
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
                        kubectl delete -f configmap.yaml -n ${env.ENV} --context=minikube --ignore-not-found
                        kubectl delete -f job.yaml -n ${env.ENV} --context=minikube --ignore-not-found
                        kubectl delete -f deployment.yaml -n ${env.ENV} --context=minikube --ignore-not-found
                        kubectl delete -f service.yaml -n ${env.ENV} --context=minikube --ignore-not-found
                        
                        kubectl apply -f configmap.yaml -n ${env.ENV} --context=minikube
                        kubectl apply -f job.yaml -n ${env.ENV} --context=minikube
                        kubectl apply -f deployment.yaml -n ${env.ENV} --context=minikube
                        kubectl apply -f service.yaml -n ${env.ENV} --context=minikube
                    """
                }
            }
        }
        stage('Exposing Keycloak') {
            when { expression { return params.KEYCLOAK } }
            steps {
                script {
                    sh """
                        if ! sudo iptables -t nat -L PREROUTING -n | grep "tcp --dport 30002 -j DNAT --to-destination 192.168.49.2:30002"; then
                            sudo iptables -t nat -A PREROUTING -p tcp --dport 30002 -j DNAT --to-destination 192.168.49.2:30002
                        fi
                    """
                }
            }
        }
    }
}
