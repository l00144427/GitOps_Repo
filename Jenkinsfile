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

            cd ${WORKSPACE}

            ls -lrt /var/jenkins_home/workspace/Terraform_master/src/calculator.java

            cd /var/jenkins_home/workspace/Terraform_master/src

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

            tar -cvf ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar *

            echo ""
            echo "Gzipping the tar package"
            echo ""

            gzip ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar

            ls -ltr
          '''
      }
    }

//  	stage('Load The Code Package To GitHub') {
//  	 	node {
//		   sh '''
//		 			echo "*************************Load The Code Package To GitHub*************************"
//          echo "To find out which line is failing"
//          withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'Git', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD']]) {
 
//            sh("git tag -a ${BUILD_NUMBER} -m 'Jenkins'")
//            echo "Another line to find out which line is failing"
//            sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@GitOps_Repo.git --tags')
//          }

//          rm ${WORKSPACE}/app_build-${BUILD_NUMBER}.tar.gz
//		 		'''
//		  }
//	  }

   // stage('Load The Code Package To GitHub') {
   //   node {
        //sshagent (credentials: ['Git']) {
        // "git add", "git commit", and "git push" your changes here. You may have to cd into the repo directory like I did here because the current working directory is the parent directory to the directory that contains the actual repo, created by "git clone" earlier in this Jenkinsfile.
        //sh("(cd reponame && git add ranger-policies/policies.json)")
        //sh("(cd reponame && git commit -m 'daily backup of ranger-policies/policies.json')")
       // sh('(cd ${WORKSPACE} && git push git@github.com:${GIT_USERNAME}/GitOps_Repo.git)')
        //}
    //  }
    //}

    stage('Push') {
      // Commit and push with ssh credentials
      withCredentials(
       [string(credentialsId: 'git-email', variable: 'GIT_COMMITTER_EMAIL'),
        string(credentialsId: 'git-account', variable: 'GIT_USERNAME'),
        string(credentialsId: 'git-name', variable: 'GIT_COMMITTER_NAME'),
        string(credentialsId: 'github-token', variable: 'GITHUB_API_TOKEN')]) {
           // Configure the user
           sh 'git config user.email "${GIT_COMMITTER_EMAIL}"'
           sh 'git config user.name "${GIT_COMMITTER_NAME}"'
           sh "git remote rm origin"
           sh "git remote add origin https://${GIT_USERNAME}:${GITHUB_API_TOKEN}@GitOps_Repo.git > /dev/null 2>&1"                     
           sh "git commit -am 'Commit message'"
           sh 'git push origin HEAD:master'
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
