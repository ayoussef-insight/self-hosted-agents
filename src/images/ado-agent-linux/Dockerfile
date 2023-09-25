ARG ARCH

FROM --platform=linux/arm64/v8 arm64v8/ubuntu:22.04 AS linux-arm64
ENV ARCH=arm64
ENV ARCHX=arm64

FROM --platform=linux/amd64 ubuntu:22.04 AS linux-amd64
ENV ARCH=amd64
ENV ARCHX=x64

FROM linux-${ARCH} AS final

ENV AGENT_VERSION=${AGENT_VERSION:-3.220.0}
LABEL author="Ahmed Youssef"
LABEL name="ado-agent-linux-${ARCH}"
LABEL description="Microsoft Azure DevOps Pipelines Self-Hosted Linux Agent"
LABEL base_image="linux-${ARCH}"
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

# Install Yarn
RUN npm install -g yarn

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash

# Install az extensions
RUN az extension add --name managementpartner

# Install azd
RUN curl -fsSL https://aka.ms/install-azd.sh | bash -s -- -a ${ARCH}

# Install bicep
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-${ARCHX} \
&& chmod a+x ./bicep \
&& mv ./bicep /usr/local/bin/bicep

# Install PowerShell core (latest)
RUN response=$(curl -s -L -I -o /dev/null -w '%{url_effective}' https://github.com/PowerShell/PowerShell/releases/latest) \
    && PSLatestVersion=$(basename "$response" | tr -d 'v') \
    && curl -Lo powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v$PSLatestVersion/powershell-$PSLatestVersion-linux-${ARCHX}.tar.gz" \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Install poweshell modules
RUN pwsh -c 'Install-Module -Name Az -Scope AllUsers -Force'

# Install .NET LTS
ENV DOTNET_ROOT="/etc/.dotnet"
RUN curl -Lo dotnet-install.sh https://dot.net/v1/dotnet-install.sh
RUN chmod +x ./dotnet-install.sh && ./dotnet-install.sh --install-dir ${DOTNET_ROOT} --channel LTS --version latest
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"

# Clean apt-get installation packages
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /home/azp

# Download the Agent
RUN curl -LSs "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${ARCHX}-${AGENT_VERSION}.tar.gz" | tar -xz

RUN adduser --disabled-password azp \
    && usermod -aG sudo azp \
    && chown -R azp /home/azp \
    && sudo echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && sudo echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

COPY ./start.sh .
RUN chmod +x start.sh
USER azp
ENTRYPOINT ["./start.sh"]
