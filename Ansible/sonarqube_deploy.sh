#!/bin/bash

echo "Running the Java Ansible playbook"
echo ""
ansible-playbook java.yml

if [[ $? -ne 0 ]];
then
    echo "The Java installation did not work as expected"
    echo ""
    echo "The script will now exit"
    exit 30
fi

echo "Running the Docker Ansible playbook"
echo ""
ansible-playbook docker.yml

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
