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
                sh 'docker-compose down || exit 0'
                sh 'docker-compose up -d --build'
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
