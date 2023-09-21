# Azure DevOps Agent

This project provides a straightforward way to configure a Docker-hosted Azure DevOps agent.

## Pre-requisites

+ Docker
+ docker-compose
+ git or git bash
+ Azure DevOps account

## Installation Steps

### Edit the values in .env for your Azure DevOps account

Use your own token from ADO -> User settings -> Personal access tokens.
The public access token needs the following custom scopes accessible by
choosing "Show all scopes".

    Scopes:
        * Agent Pools (Read & manage)
        * Deployment Groups (Read & manage)

### Build & Start the agent

```bash
docker-compose up --build -d --scale agent=2
```

### Start from docker

```bash
docker run -it -d --name "{docker_instance_name}" --restart=always -e AZP_URL="https://dev.azure.com/{organisation}" -e AZP_TOKEN="{PAT}" -e NAME="{agent_name}" -e AZP_POOL="{agent_pool_name}" ado-agents/{image_name}:latest
```

### Tag Docker Image

```bash
docker tag ado-agents/{image_name}:latest {repository_name}.azurecr.io/ado-agents/{image_name}:v1
```

### Push image to ACR

```bash
docker push {repository_name}.azurecr.io/ado-agents/{image_name}:{image_version}
```

### Install docker on linux

Follow steps from this [Url](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)

### Pull and run from ACR

```bash
az login

az acr login --name {repository_name}

docker pull {repository_name}.azurecr.io/ado-agents/{image_name}:{image_version}

docker run -it -d --name "{docker_instance_name}" --restart=always -e AZP_URL="https://dev.azure.com/{organisation}" -e AZP_TOKEN="{PAT}" -e AZP_AGENT_NAME="{agent_name}" -e AZP_POOL="{agent_pool_name}" {repository_name}.azurecr.io/ado-agents/{image_name}:{image_version}
```
