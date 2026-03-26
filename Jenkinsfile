pipeline {
    agent any
environment {
        // This binds the keys to the standard Terraform environment variables
        AWS_CREDS = credentials('aws-cred-id')
    } 
  stages {

  stage('Checkout') {
    steps {

  git branch: "main",
  url: "https://github.com/Shrikant155/ec2-cicd-deploy-web.git",
  credentialsId:"github-cred-id"

      }
       }
stage('Terraform Init & Import') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-cred-id',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            // 1. THIS IS THE FIX: Tell Jenkins to go into the sub-folder
            dir('terraform-aws') { 
                sh 'terraform init'
                
                script {
                    def bucketName = "shrik-s3-bucket-96741"
                    // Now this runs INSIDE terraform-aws folder
                    sh "terraform import aws_s3_bucket.my_bucket ${bucketName} || echo 'Already in state'"
                }
            }
        }
    }
}

stage('Terraform Apply') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-cred-id',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            // 2. MUST also use 'dir' here for apply to find the files
            dir('terraform-aws') {
                sh 'terraform apply -auto-approve'
            }
        }
    }
}

 stage('build imgage') {
     steps {

      sh "docker build -t webapp2 ."

    }
  }
  stage('login') {
  steps {
      withCredentials([usernamePassword(
      credentialsId:"dockerhub-cred-id",
      usernameVariable: "USER",
      passwordVariable: "PASS"

   )]) {
       sh '''
       echo $PASS | docker login -u $USER --password-stdin
       ''' 
    }
  }
}
  stage('push'){
     steps {
       sh '''
       docker tag webapp2 shrikant155/webapp2:latest
       docker push shrikant155/webapp2:latest
       '''

     }
     }
    stage('deploy to ec2'){
       steps{
script {
            
            dir('terraform-aws') {
                // Get the raw IP from the output we just defined
               env.EC2_IP = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()
            }
            
            if (env.EC2_IP == "" || env.EC2_IP.contains("Warning")) {
                error "Could not find EC2 IP. Check if Terraform Apply was successful."
            }

            echo "Target IP: ${env.EC2_IP}"
       sshagent(['ec2-key']){
          sh """
          ssh -o StrictHostKeyChecking=no ec2-user@${env.EC2_IP} ' 
          docker rm -f myweb2 || true &&
          docker pull shrikant155/webapp2:latest &&
          docker  run -d -p 8081:80  --name myweb2 shrikant155/webapp2:latest
           '
          """

          } 
       }
    }

}
}
}
