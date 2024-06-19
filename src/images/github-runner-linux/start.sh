#!/bin/bash
set -e

if [ -z "$GITHUB_REPOSITORY" ]; then
  echo 1>&2 "GITHUB_REPOSITORY is not set"
  exit 1
fi

if [ -z "$GITHUB_TOKEN_FILE" ]; then
  if [ -z "$GITHUB_TOKEN" ]; then
    echo 1>&2 "error: missing GITHUB_TOKEN environment variable"
    exit 1
  fi

  GITHUB_TOKEN_FILE=.token
  echo -n $GITHUB_TOKEN > "$GITHUB_TOKEN_FILE"
fi

unset GITHUB_TOKEN

GITHUB_REPOSITORY=$GITHUB_REPOSITORY
GITHUB_TOKEN=$(cat "$GITHUB_TOKEN_FILE")
NAME=${NAME:-"hosted-runner-01"}

print_header() {
  lightcyan='\033[1;36m'
  nocolor='\033[0m'
  echo -e "${lightcyan}$1${nocolor}"
}

print_header "1. Getting github runner registration token..."

TOKEN=$(curl -X POST -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token | jq -r .token)

print_header "2. Configuring github actions runner..."

./config.sh \
  --unattended \
  --name "${NAME:-$HOSTNAME}" \
  --replace \
  --url https://github.com/$GITHUB_REPOSITORY \
  --token $TOKEN

cleanup() {
    print_header "Removing github actions runner..."
    ./config.sh remove \
      --unattended \
      --token $TOKEN
}

trap 'cleanup; exit 0' EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

print_header "3. Running github actions runner..."

./run.sh & wait $!