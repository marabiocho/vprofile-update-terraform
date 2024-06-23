pipeline {
    agent {
        docker { image 'kantin10/terraform-aws-cli:v1'}
            
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/marabiocho/vprofile-update-terraform.git', branch: 'main'
            }
        }

        

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Refresh') {
            steps {
                sh 'terraform refresh'
            }
        }

        stage('Terraform format') {
            steps {
                sh 'terraform fmt'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Terraform Destroy') {
            steps {
                sh 'terraform destroy --auto-approve'
            }
        }
    }
}
