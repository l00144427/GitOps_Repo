// Jenkinsfile
String credentialsId = 'awsCredentials'

try {
  stage('Code Checkout') {
    node {
      cleanWs()
      checkout scm
    }
  }

  // Run terraform init
  stage('Terraform Init') {
    node {
      withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: credentialsId,
        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ]]) {
        ansiColor('xterm') {
          // Using TF_LOG=DEBUG here to provide greater debug logs
          sh 'TF_LOG=DEBUG terraform init'
        }
      }
    }
  }

  // Run terraform plan
  stage('Terraform Plan') {
    node {
      withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: credentialsId,
        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
      ]]) {
        ansiColor('xterm') {
          sh 'terraform plan'
        }
      }
    }
  }

  if (env.BRANCH_NAME == 'master') {

    // Run terraform apply
    stage('Terraform Apply') {
      node {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: credentialsId,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          ansiColor('xterm') {
            sh 'terraform apply -auto-approve'
          }
        }
      }
    }

    // Run terraform show
    stage('Terraform Show') {
      node {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: credentialsId,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          ansiColor('xterm') {
            sh 'terraform show'
          }
        }
      }
    }

    stage('Build & Tar Package') {
      node {
        sh '''
            echo "*************************Build & Tar Package*************************"
            cd ${WORKSPACE}
            touch app_build-${BUILD_NUMBER}.txt
            javac -cp ${WORKSPACE}/src calculator.class
            if [[ $? -ne 0 ]];
            then
              echo "The compilation of the Java code did not work as expected"
              echo ""
              echo "The script will now exit"
              exit 30
            fi
 
            java calculator
 
             if [[ $? -ne 0 ]];
            then
              echo "Running the Java application did not work as expected"
              echo ""
              echo "The script will now exit"
              exit 30
            fi

            tar -cvf ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar *
            ls -ltr
          '''
      }
    }

  	// stage('Load To Artifactory') {
  	// 	node {
		// 	sh '''
		// 			echo "*************************Load To Artifactory*************************"
		// 			echo "curl command pushes the new package into Artifactory"
		// 			curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} -X PUT "${ARTIFACTORY_SERVER}:${ARTIFACTORY_PORT}/artifactory/app-release-local/com/app/build/app_build-${BUILD_NUMBER}/app_build-${BUILD_NUMBER}.tar" -T ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar
		//   		rm ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar
		// 		'''
		//   }
	  // }


  	stage('Deploy App & Ansible Code') {
	   	node {
		    	sh '''
			    	echo "*************************Deploy App & Ansible Code*************************"
            cd ${WORKSPACE}/ansible
            ./sonarqube_deploy.sh
            cd ${WORKSPACE}
		  		  ls -ltr
			    '''
  		}
  	}
  }
  currentBuild.result = 'SUCCESS'
}
catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException flowError) {
  currentBuild.result = 'ABORTED'
}
catch (err) {
  currentBuild.result = 'FAILURE'
  throw err
}
finally {
  if (currentBuild.result == 'SUCCESS') {
    currentBuild.result = 'SUCCESS'
  }
}
