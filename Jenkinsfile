pipeline {
    agent any

    stages {
        stage('Clonar repositorio') {
            steps {
                checkout scm
            }
        }

        stage('Construir y levantar servicios') {
            steps {
                script {
                    // Detiene servicios si ya están corriendo
                    sh 'docker-compose down || true'

                    // Construye y levanta
                    sh 'docker-compose up -d --build'
                }
            }
        }

        stage('Verificar contenedores') {
            steps {
                sh 'docker ps'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finalizado.'
        }
    }
}

