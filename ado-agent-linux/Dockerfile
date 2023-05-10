FROM --platform=linux/amd64 ubuntu:22.04

ARG AGENT_VERSION="3.220.0"
LABEL author="Ahmed Youssef"
LABEL name="ado-agent-linux"
LABEL description="Microsoft Azure DevOps Pipelines Self-Hosted Linux Agent"
LABEL base_image="ubuntu:22.04"
LABEL agent_version=$AGENT_VERSION

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
        gnupg-agent \
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
        dnsutils \
        iputils-ping \
        net-tools

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
&& apt-get install -y nodejs

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash

# Install az extensions
RUN az extension add --name managementpartner

# Install azd (locked to 0.8.0-beta.2 as azd is still in beta)
RUN curl -Lo install-azd.sh https://aka.ms/install-azd.sh
RUN chmod +x ./install-azd.sh && ./install-azd.sh --version 0.8.0-beta.2

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
RUN pwsh -c 'Install-Module -Name Az -Scope AllUsers -Force'

# Install .NET 6.0
ENV DOTNET_ROOT="/etc/.dotnet"
RUN curl -Lo dotnet-install.sh https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh && ./dotnet-install.sh --install-dir ${DOTNET_ROOT} --architecture amd64 --channel 6.0 --version latest
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"

# Clean apt-get installation packages
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /azp

# Install  ADO Agent
RUN curl -LSs "https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz" | tar -xz

# Run the agent
COPY ./start.sh .
RUN chmod +x start.sh
ENTRYPOINT [ "./start.sh" ]
