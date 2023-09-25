ARG ARCH

FROM --platform=linux/arm64/v8 arm64v8/ubuntu:22.04 AS linux-arm64
ENV ARCH=arm64
ENV ARCHX=arm64

FROM --platform=linux/amd64 ubuntu:22.04 AS linux-amd64
ENV ARCH=amd64
ENV ARCHX=x64

FROM linux-${ARCH} AS final

ARG RUNNER_VERSION
LABEL author="Ahmed Youssef"
LABEL name="github-runner-linux"
LABEL description="Github Self-Hosted Linux Actions Runner"
LABEL base_image="linux-${ARCH}"
LABEL RUNNER_VERSION=$RUNNER_VERSION

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

WORKDIR /home/runner

RUN curl -LSs "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCHX}-${RUNNER_VERSION}.tar.gz" | tar -xz & wait $!

# install dependencies
# RUN ./bin/installdependencies.sh

# Run the agent
RUN adduser --disabled-password runner \
    && usermod -aG sudo runner \
    && chown -R runner /home/runner \
    && sudo echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && sudo echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

COPY ./start.sh .
RUN chmod +x start.sh
USER runner
ENTRYPOINT ["./start.sh"]