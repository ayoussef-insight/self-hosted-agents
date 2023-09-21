if (-not (Test-Path Env:GITHUB_REPOSITORY)) {
  Write-Error "error: missing GITHUB_REPOSITORY environment variable"
  exit 1
}

if (-not (Test-Path Env:GITHUB_TOKEN_FILE)) {
  if (-not (Test-Path Env:GITHUB_TOKEN)) {
    Write-Error "error: missing GITHUB_TOKEN environment variable"
    exit 1
  }

  $Env:GITHUB_TOKEN_FILE = "\actions-runner\.token"
  $Env:GITHUB_TOKEN | Out-File -FilePath $Env:GITHUB_TOKEN_FILE
}

Remove-Item Env:GITHUB_TOKEN

$GITHUB_REPOSITORY=$Env:GITHUB_REPOSITORY
$GITHUB_TOKEN=$(Get-Content $Env:GITHUB_TOKEN_FILE)
$Name = if ($env:NAME) { $env:NAME } else { "hosted-runner-01" }

try
{
  Write-Host "1. Getting github runner registration token..." -ForegroundColor Cyan

  $Token = (Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token" -Headers @{ "Authorization" = "token $GITHUB_TOKEN" }).token;

  Write-Host "2. Configuring github actions runner..." -ForegroundColor Cyan

  .\config.cmd --unattended `
    --name "$Name" `
    --url "https://github.com/$GITHUB_REPOSITORY" `
    --token "$Token" `
    --replace

  Write-Host "3. Running github actions runner..." -ForegroundColor Cyan

  .\run.cmd
}
finally
{
  Write-Host "Cleanup. Removing github actions runner..." -ForegroundColor Cyan

  .\config.cmd remove --unattended `
    --token "$Token"
}