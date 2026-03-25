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
stage('Terraform') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-cred-id', 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
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
      passwordVariable:"PASS"

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
                    // Get the EC2 public IP from Terraform output
                    def ec2_ip = sh(script: "cd terraform-aws && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    echo "EC2 IP: ${ec2_ip}"
       sshagent(['ec2-key']){
          sh '''
          ssh -o StrictHostKeyChecking=no ec2-user@${ec2_ip} " 
          docker rm -f myweb2 || true &&
          docker pull shrikant155/webapp2:latest &&
          docker  run -d -p 8081:80  --name myweb2 shrikant155/webapp2:latest
           "  
          '''

          } 
       }
    }


    }

}
}
