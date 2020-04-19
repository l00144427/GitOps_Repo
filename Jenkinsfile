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
        sh '''
          echo "Running Terraform init at `date`"
          #terraform init
        '''
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
        sh '''
           echo "Running Terraform plan at `date`"
           #terraform plan
        '''
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
        sh '''
          echo "Running Terraform apply at `date`"
          #terraform apply -auto-approve
        '''
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
        sh '''
          echo "Running Terraform show at `date`"
          #terraform show
        '''
        }
      }
    }
  }

  stage('Execute The Ansible playbooks') {
    node {
      sh '''
        cd ${WORKSPACE}/Ansible

        echo "Running the Java Ansible playbook at `date`"
        echo ""

#        ansible-playbook java.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Java installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the Docker Ansible playbook at `date`"
        echo ""

#        ansible-playbook docker.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Docker installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the Sonarqube Ansible playbook at `date`"
        echo ""

        ansible-playbook sonarqube.yml

        if [[ $? -ne 0 ]];
        then
            echo "The Sonarqube installation did not work as expected"
            echo ""
            echo "The script will now exit"
            exit 30
        fi

        echo "Running the JUnit Ansible playbook at `date`"
        echo ""

        ansible-playbook junit.yml

        if [[ $? -ne 0 ]];
        then
            echo "The JUnit installation did not work as expected"
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
        echo "Compiling the Code & the JUnit tests at `date`"
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
        echo "Running the JUnit tests at `date`"
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
        echo ""
        echo "Running the Code Through Sonarqube at `date`"
        echo ""
        sleep 10
        cd ${WORKSPACE}/
        ./gradlew sonarqube \
        -Dsonar.projectKey=GitOps_Repo \
        -Dsonar.host.url=http://ec2-3-249-230-178.eu-west-1.compute.amazonaws.com:9000
        '''
    }
  }

  stage('Build & Tar Package') {
    node {
      sh '''
          echo "*************************Build & Tar Package*************************"

          cd ${WORKSPACE}/build/libs

          echo ""
          echo "Adding the compiled code into a tar package at `date`"
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
          echo "Gzipping the tar package at `date`"
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
        echo ""
        echo "Loading The Code Package To GitLab at `date`"
        echo ""
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
        echo "Running the Application Ansible playbook at `date`"
        echo ""

        cd ${WORKSPACE}/Ansible

        ansible-playbook --extra-vars "buildnum=${BUILD_NUMBER}" application.yml

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

  stage('Create a Docker image') {
	 	node {
	   	sh '''
	    	echo "*************************Create a Docker image*************************"
        echo ""
        echo "Create the Docker image at `date`"
        echo ""

        cd ${WORKSPACE}/Ansible

        ansible-playbook docker_image.yml
	    '''
    }
  }

  stage('Upload the Docker image') {
	 	node {
	   	sh '''
	    	echo "*************************Upload the Docker image*************************"
        echo ""
        echo "Upload the Docker image at `date`"
        echo ""

        cd ${WORKSPACE}/Ansible

        ansible-playbook docker_image_upload.yml
	    '''
    }
  }

  stage('Test The Application') {
	 	node {
	   	sh '''
	    	echo "*************************Test The Application*************************"
        echo ""
        echo "Test the Docker container at `date`"
        echo ""

        cd ${WORKSPACE}/Ansible

        #ansible-playbook docker_container_test.yml
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
