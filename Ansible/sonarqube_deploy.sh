#!/bin/bash

echo "Running the Java Ansible playbook"
echo ""
ls -lrt /usr/local/bin/ansible-playbook
/usr/local/bin/ansible-playbook java.yml

if [[ $? -ne 0 ]];
then
    echo "The Java installation did not work as expected"
    echo ""
    echo "The script will now exit"
    exit 30
fi

echo "Running the JUnit Ansible playbook"
echo ""
/usr/local/bin/ansible-playbook junit.yml

if [[ $? -ne 0 ]];
then
    echo "The JUnit installation did not work as expected"
    echo ""
    echo "The script will now exit"
    exit 30
fi

echo "Running the Docker Ansible playbook"
echo ""
/usr/local/bin/ansible-playbook docker.yml

if [[ $? -ne 0 ]];
then
    echo "The Docker installation did not work as expected"
    echo ""
    echo "The script will now exit"
    exit 30
fi

echo "Running the Sonarqube Ansible playbook"
echo ""
/usr/local/bin/ansible-playbook sonarqube.yml

if [[ $? -ne 0 ]];
then
    echo "The Sonarqube installation did not work as expected"
    echo ""
    echo "The script will now exit"
    exit 30
fi
