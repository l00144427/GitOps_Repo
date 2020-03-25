// Jenkinsfile
String credentialsId = 'awsCredentials'
String GitHubcredentialsId = 'l00144427@student.lyit.ie/******'

try {
  stage('checkout') {
    node {
      cleanWs()
      checkout scm
    }
  }

  // Run terraform init
  stage('init') {
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
  stage('plan') {
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
    stage('apply') {
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
    stage('show') {
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

    // Pull the code from GitHub
    stage('GitHub Pull') {
	  	node {
		  	sh 'echo "*************************GitHub Pull*************************"'
			  script {
				  checkout([$class: 'GitSCM',
   		   	  branches: [[name: '*/master']],
    			  doGenerateSubmoduleConfigurations: false,
    			  extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "l00144427/GitOps_Repo"]],
    			  submoduleCfg: [],
   			    userRemoteConfigs: [[url: 'git@github.com:l00144427/GitOps_Repo']]
    		  ])
			  }
		  }
	  }

  	stage('Reconfigure Files') {
	   	node {
		    	sh '''
			    	echo "*************************Reconfigure Files*************************"
				    cd ${WORKSPACE}
  				  mkdir package
	  			  cd ${WORKSPACE}/l00144427/GitOps_Repo
		  	//	mv services ${WORKSPACE}/package
  			//	cd ${WORKSPACE}/package
	  		//	touch doodle_build-${BUILD_NUMBER}.txt
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
