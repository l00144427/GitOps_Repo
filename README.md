# GitOps_Repo
Repository for the GitOps Pipeline

## Introduction

This repository contains the Jenkins code that was used to create the GitOps pipeline, the Terraform code that was required to automatically provision the Ubuntu Linux servers that host the application and it also hosts the Ansible code that ensures the required software is installed on those Ubuntu Linux servers.

### Resources

Emmet O'Donnell & Ruth G. Lennon

## Project Deadline

6th May 2020

## Project Specification

A GitOps pipeline should be coded which can:

- Be created automatically
- On a commit from a Developer the infrastructure and application code should be taken from a GitHub repository
- Any infrastructure should be created if not already in place and updated if changes are required
- The application code should be run through a series of tests including JUnit & Sonarqube
- On success of those tests the code should be packaged & deployed to a GitLab repository
- The code should then be deployed to the application server & a test performed, if possible, to ensure at least basic functionality is working as expected

## Project Overview



## Useful Links

- GitHub: https://github.com/l00144427/GitOps_Repo.git
- GitLab - https://gitlab.com/l00144427/GitOps_Repo.git
- GitLab Container Registry - https://gitlab.com/l00144427/GitOps_Repo/container_registry
- Docker - https://hub.docker.com/repository/docker/l00144427/gitops_repo
- AWS: https://eu-west-1.console.aws.amazon.com/console/home?region=eu-west-1#
- Jenkins: https://ec2-18-202-223-165.eu-west-1.compute.amazonaws.com:8080
- Sonarqube: https://ec2-3-248-252-11.eu-west-1.compute.amazonaws.com:9000/projects?sort=-analysis_date
- Artifactory: https://ec2-3-248-252-11.eu-west-1.compute.amazonaws.com:8082/ui/login/
