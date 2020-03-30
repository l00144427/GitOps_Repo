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

  stage('Execute The Ansible Scripts') {
    node {
      cd ${WORKSPACE}/Ansible

      chmod 750 sonarqube_deploy.sh

      ./sonarqube_deploy.sh

      if [[ $? -ne 0 ]];
      then
        echo "The execution of the Ansible scripts did not work as expected"
        echo ""
        echo "The script will now exit"
        exit 30
       fi
    }
  }

  stage('Run Code Through JUnit') {
    node {
      echo "*************************Run Code Through JUnit*************************"
    }
  }

  stage('Run Code Through Sonarqube') {
    node {
      echo "*************************Run Code Through Sonarqube*************************"
    }
  }

  stage('Build & Tar Package') {
    node {
      sh '''
          echo "*************************Build & Tar Package*************************"

          cd ${WORKSPACE}/src

          echo ""
          echo "Compiling the Java code"
          echo ""

          javac -cp ${WORKSPACE}/src calculator.java

          if [[ $? -ne 0 ]];
          then
            echo "The compilation of the Java code did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
          fi

          echo ""
          echo "Adding the compiled code into a tar package"
          echo ""

          tar -cvf ${WORKSPACE}/packages/app_build-${BUILD_NUMBER}.tar *

          if [[ $? -ne 0 ]];
          then
            echo "Adding the compiled code into a tar package did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
          fi

          echo ""
          echo "Gzipping the tar package"
          echo ""

          gzip ${WORKSPACE}/packages/app_build-${BUILD_NUMBER}.tar

          if [[ $? -ne 0 ]];
          then
            echo "Gzipping the tar package did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
          fi

          ls -ltr
      '''
    }
  }

  stage('Load The Code Package To GitLab') {
  // Commit and push with ssh credentials
    environment { 
      GIT_AUTH = credentials('GitLab') 
    }
    node {
      sh('''
        git config user.name 'l00144427'
        git config user.email 'l00144427@student.lyit.ie'
        git config --local credential.helper "!f() { echo username=\\l00144427@student.lyit.ie; echo password=\\$GIT_PASSWORD; }; f"
        git remote add upstream https://gitlab.com/l00144427/GitOps_Repo.git
        git add packages/app_build-${BUILD_NUMBER}.tar.gz
        git commit -am "Pushing build number ${BUILD_NUMBER} to GitLab"
        git pull upstream HEAD:master
        git push upstream HEAD:master
   ''')
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

  	stage('Deploy The Application & Ansible Code') {
	   	node {
		    	sh '''
			    	echo "*************************Deploy App & Ansible Code*************************"
            cd ${WORKSPACE}/Ansible
            ./sonarqube_deploy.sh
			    '''
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
