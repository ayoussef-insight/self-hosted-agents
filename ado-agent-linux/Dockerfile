FROM --platform=linux/amd64 ubuntu:22.04

LABEL author="Ahmed Youssef"
LABEL name="ado-agent-linux"
LABEL description="Microsoft Azure DevOps Self-Hosted Linux Agent"
LABEL base_image="ubuntu:22.04"
LABEL agent_version="2.217.2"

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get install -y -qq --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        apt-utils \
        iputils-ping \
        curl \
        file \
        git \
        gnupg \
        locales \
        sudo \
        time \
        unzip \
        wget \
        zip \
        jq \
        libcurl4 \
        netcat \
        software-properties-common \
        build-essential \
        python3 \
        python3-pip \
        nodejs

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash

# Install az extensions
RUN az extension add --name managementpartner

# Install bicep
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
&& chmod a+x ./bicep \
&& sudo mv ./bicep /usr/local/bin/bicep

# Install powershell
RUN wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb" \
&& dpkg -i packages-microsoft-prod.deb \
&& apt-get update \
&& apt-get install -y powershell \
&& rm packages-microsoft-prod.deb

# Install poweshell modules
# RUN pwsh -c 'Install-Module -Name Az -Scope AllUsers -Force'

# Clean apt-get installation packages
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /azp

# Install  ADO Agent
RUN curl -LSs "https://vstsagentpackage.azureedge.net/agent/2.217.2/vsts-agent-linux-x64-2.217.2.tar.gz" | tar -xz

# Install older version of libsssl to work with the current version of ado agent
RUN wget -q "http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb" \
&& sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
&& rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Run the agent
COPY ./start.sh .
RUN chmod +x start.sh
ENTRYPOINT [ "./start.sh" ]
