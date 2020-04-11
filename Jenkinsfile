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
          sh 'terraform init'
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

  stage('Execute The Ansible playbooks') {
    node {
      sh '''
        cd ${WORKSPACE}/Ansible

        echo "Running the Java Ansible playbook"
        echo ""

        # ansible-playbook java.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Java installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the JUnit Ansible playbook"
        echo ""

        # ansible-playbook junit.yml

        if [[ $? -ne 0 ]];
        then
            echo "The JUnit installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the Docker Ansible playbook"
        echo ""

        # ansible-playbook docker.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Docker installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the Sonarqube Ansible playbook"
        echo ""

        ansible-playbook sonarqube.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Sonarqube installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi
      '''
    }
  }

  stage('Run Code Through JUnit') {
    node {
      sh '''
        echo "*************************Run Code Through JUnit*************************"
        cd ${WORKSPACE}/

        echo ""
        echo "Compiling the Code & the JUnit tests"
        echo ""

        chmod 755 ./gradlew

        ./gradlew jar

        if [[ $? -ne 0 ]];
        then
          echo "The compilation of the Code & JUnit Test did not work as expected"
          echo ""
          echo "The script will now exit"
          exit 30
        fi

        echo ""
        echo "Running the JUnit tests"
        echo ""

        ./gradlew test

        if [[ $? -ne 0 ]];
        then
          echo "The execution of the JUnit Test did not work as expected"
          echo ""
          echo "The script will now exit"
          exit 30
        fi
      '''
    }
  }

  stage('Run Code Through Sonarqube') {
    node {
      sh '''
        cd ${WORKSPACE}/
        ./gradlew sonarqube \
        -Dsonar.projectKey=GitOps_Repo \
        -Dsonar.host.url=http://172.31.3.233:9000
        --info
        '''
    }
  }

  stage('Build & Tar Package') {
    node {
      sh '''
          echo "*************************Build & Tar Package*************************"

          cd ${WORKSPACE}/build/libs

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

          ls -ltr ${WORKSPACE}/packages
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

  stage('Deploy The Application Code') {
	 	node {
	   	sh '''
	    	echo "*************************Deploy The Application Code*************************"
        echo ""
        echo "Running the Java Ansible playbook"
        echo ""

        cd ${WORKSPACE}/Ansible

        ansible-playbook application.yml

        if [[ $? -ne 0 ]];
        then
            echo "The deployment of the application code did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi
	    '''
    }
  }


  stage('Test The Application') {
	 	node {
	   	sh '''
	    	echo "*************************Test The Application*************************"
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
