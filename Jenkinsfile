// Jenkinsfile
String credentialsId = 'awsCredentials'

try {
  stage('Code Checkout') {
    node {
      cleanWs()
      checkout scm
    }
  }

  stage('Build & Tar Package') {
    node {
      sh '''
          echo "*************************Build & Tar Package*************************"

          cd ${WORKSPACE}/src

          // Create the packages folder where the compiled code will go
          sudo mkdir ${WORKSPACE}/packages

          sudo chown -R jenkins:jenkins ${WORKSPACE}/packages

          echo ""
          echo "Creating the compiled code"
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

          echo ""
          echo "Gzipping the tar package"
          echo ""

          gzip ${WORKSPACE}/packages/app_build-${BUILD_NUMBER}.tar

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


  	stage('Deploy App & Ansible Code') {
	   	node {
		    	sh '''
			    	echo "*************************Deploy App & Ansible Code*************************"
            cd ${WORKSPACE}/Ansible
            ./sonarqube_deploy.sh
            cd ${WORKSPACE}
		  		  ls -ltr
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
