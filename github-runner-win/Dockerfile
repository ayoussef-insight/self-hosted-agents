ARG DOTNET_VERSION=4.8
# 4.8 for .NET framework 4.8
# 4.6.2 for .NET framework 4.6.2
# 3.5 for .NET framework 4.7.2, 3.5, 3.0, 2.5
FROM mcr.microsoft.com/dotnet/framework/sdk:${DOTNET_VERSION}

ARG RUNNER_VERSION
LABEL author="Ahmed Youssef"
LABEL name="github-runner-win"
LABEL description="Github Self-Hosted Windows Actions Runner"
LABEL base_image="win-%DOTNET_VERSION%"
LABEL RUNNER_VERSION=$RUNNER_VERSION

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;"]

# Install PowerShell Core
RUN (New-Object Net.WebClient).DownloadFile('https://aka.ms/install-powershell.ps1', '.\install-powershell.ps1'); \
    ./install-powershell.ps1 -UseMSI -Quiet; \
    Remove-Item .\install-powershell.ps1

# Install NuGet Provider for powershell
RUN Install-PackageProvider -Name NuGet -Force

# Install poweshell modules
RUN Install-Module -Name Az -Scope AllUsers -Force

# Install Azure CLI (latest)
RUN (New-Object Net.WebClient).DownloadFile('https://aka.ms/installazurecliwindows', '.\AzureCLI.msi'); \
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; \
    Remove-Item .\AzureCLI.msi

# Install az extensions
RUN az extension add --name managementpartner

# Install bicep CLI (latest)
RUN $installPath = $env:USERPROFILE + '\.bicep'; \
    $installDir = New-Item -ItemType Directory -Path $installPath -Force ; \
    $installDir.Attributes += 'Hidden'; \
    (New-Object Net.WebClient).DownloadFile('https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe', $installPath + '\bicep.exe'); \
    $currentPath = (Get-Item -path 'HKCU:\Environment' ).GetValue('Path', '', 'DoNotExpandEnvironmentNames'); \
    if (-not $currentPath.Contains('%USERPROFILE%\.bicep')) { setx PATH ($currentPath + ';%USERPROFILE%\.bicep') } ; \
    if (-not $env:path.Contains($installPath)) { $env:path += ';' + $installPath }

# Install .NET (LTS)
RUN (New-Object Net.WebClient).DownloadFile('https://dot.net/v1/dotnet-install.ps1', '.\dotnet-install.ps1'); \
    ./dotnet-install.ps1 -Channel 'LTS' ; \
    Remove-Item .\dotnet-install.ps1; \
    $installPath = $env:LocalAppData + '\Microsoft\dotnet'; \
    $currentPath = (Get-Item -path 'HKCU:\Environment' ).GetValue('Path', '', 'DoNotExpandEnvironmentNames'); \
    if (-not $currentPath.Contains($installPath)) { setx PATH ($currentPath + ';' + $installPath) } ; \
    if (-not $env:path.Contains($installPath)) { $env:path += ';' + $installPath }

# Install Node 18
RUN (New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v18.16.1/node-v18.16.1-x64.msi', '.\node.msi'); \
    Start-Process msiexec.exe -Wait -ArgumentList '/I node.msi /quiet'; \
    Remove-Item .\node.msi;

# Install Yarn (latest)
RUN npm install --global yarn

# Cleanup Az
RUN $AzDataPath = $env:USERPROFILE + '\.azure'; Remove-Item -Path $AzDataPath -Recurse

WORKDIR /actions-runner

# Download the Agent
RUN $agentUrl = 'https://github.com/actions/runner/releases/download/v' + $env:RUNNER_VERSION + '/actions-runner-win-x64-' + $env:RUNNER_VERSION + '.zip'; \
    (New-Object Net.WebClient).DownloadFile($agentUrl, '.\actions-runner.zip'); \
    Expand-Archive -Path .\actions-runner.zip -DestinationPath .\ -Force; \
    Remove-Item .\actions-runner.zip;

COPY start.ps1 .

CMD powershell .\start.ps1