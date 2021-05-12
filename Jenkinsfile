pipeline {
  agent any
  tools {
  
  maven 'maven'
   
  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/vijay2181/devops-sprIngboot-CICD.git']]])
        }
      }
	  
	  stage ('Build')  {
	      steps {
          
            
            sh "mvn package"
          
        }
         
      }
   
     stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {
                
				
                 sh 'mvn -U clean install sonar:sonar'
                }
				
              }
            
      }

    stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "jfrog",
                    url: "http://3.235.141.37:8081/artifactory",
                    credentialsId: "jfrog"
                )

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "jfrog",
                    snapshotRepo: "libs-snapshot-local"
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "jfrog",
                    snapshotRepo: "libs-snapshot"
                )
            }
    }

    stage ('Deploy Artifacts') {
            steps {
                rtMavenRun (
                    tool: maven, // Tool name from Jenkins configuration
                    pom: 'pom.xml',
                    goals: 'clean deploy',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
         }
    }

    stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "jfrog"
             )
        }
    }

    stage('Copy Dockerfile & Playbook to Ansible Server') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "scp -o StrictHostKeyChecking=no dockerfile root@3.87.82.116:/root/admin"
                        sh "scp -o StrictHostKeyChecking=no play.yml root@3.87.82.116:/root/admin"
                    }
                }
            
        } 
    stage('Build Container Image') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no root@3.87.82.116 -C \"sudo ansible-playbook play.yml\""
                        
                    }
                }
            
        } 
    stage('Copy Deployment & Service Defination to K8s Master') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "scp -o StrictHostKeyChecking=no deployment.yml root@3.235.229.232:/root"
                        sh "scp -o StrictHostKeyChecking=no nodeport.yml root@3.235.229.232:/root"
                    }
                }
            
        } 

    stage('Waiting for Approvals') {
            
        steps{

				input('Test Completed ? Please provide  Approvals for Prod Release ?')
			  }
            
    }     
    stage('Deploy Artifacts to Production') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no root@3.235.229.232 -C \"sudo kubectl apply -f deployment.yml\""
                        sh "ssh -o StrictHostKeyChecking=no root@3.235.229.232 -C \"sudo kubectl apply -f nodeport.yml\""
                        
                    }
                }
            
        } 
         
   } 
}
