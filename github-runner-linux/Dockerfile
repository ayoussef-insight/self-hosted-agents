FROM --platform=linux/amd64 ubuntu:22.04

LABEL author="Ahmed Youssef"
LABEL name="github-runner-linux"
LABEL description="Microsoft Girhub Self-Hosted Linux Runner"
LABEL base_image="ubuntu:22.04"
LABEL runner_version="2.302.1"

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get install -y -qq --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        apt-utils \
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

WORKDIR /github_runner

RUN curl -LSs "https://github.com/actions/runner/releases/download/v2.302.1/actions-runner-linux-x64-2.302.1.tar.gz" | tar -xz & wait $!

# install dependencies
# RUN ./bin/installdependencies.sh

# Run the agent
COPY ./start.sh .
RUN chmod +x start.sh
RUN chown -R daemon /github_runner
USER daemon
ENTRYPOINT ["./start.sh"]