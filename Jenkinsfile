pipeline {
    agent {
        docker { image 'kantin10/terraform-aws-cli:v1'}
            
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/marabiocho/Vprofile-terrafom-code.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform plan') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
