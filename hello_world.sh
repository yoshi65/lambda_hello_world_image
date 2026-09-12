#!/usr/bin/env bash

set -euo pipefail

profile="default"
delete=false
ecr_name="dummy"
tag="latest"
architecture="amd64"

usage_exit() {
  echo "usage: ./hello_world.sh [-d] [-p profile] [-n ecr_name] [-t tag] [-a architecture]"
  exit 1
}

while getopts ":a:dp:n:t:h" OPT
do
    case $OPT in
        a)  architecture=$OPTARG
            ;;
        p)  profile=$OPTARG
            ;;
        n)  ecr_name=$OPTARG
            ;;
        t)  tag=$OPTARG
            ;;
        d)  delete=true
            ;;
        h)  usage_exit
            ;;
        :)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

# Delete ecr
if [[ "$delete" == true ]]; then
  aws ecr delete-repository --profile "$profile" --repository-name "$ecr_name" --force
  echo "Deleted $ecr_name"
  exit 0
fi

case "$architecture" in
    amd64|arm64) ;;
    *)
        echo "architecture must be amd64 or arm64" >&2
        exit 1
        ;;
esac

if ! command -v aws >/dev/null || ! command -v docker >/dev/null; then
  echo "AWS CLI v2 and Docker with buildx are required" >&2
  exit 1
fi

region=$(aws configure get region --profile "$profile")
if [[ -z "$region" ]]; then
  echo "No AWS Region is configured for profile '$profile'" >&2
  exit 1
fi

account_id=$(aws sts get-caller-identity --profile "$profile" --output text --query Account)

# Create ECR
if ! aws ecr describe-repositories --profile "$profile" --repository-names "$ecr_name" >/dev/null 2>&1; then
  aws ecr create-repository --profile "$profile" --repository-name "$ecr_name" \
    --image-scanning-configuration scanOnPush=true
  echo "Created ecr $ecr_name"
else
  echo "ecr $ecr_name already exists"
fi

# Build docker image
docker buildx build --platform "linux/$architecture" --provenance=false --load \
  --tag "${ecr_name}:${tag}" .

# Set docker tag
repository_uri="${account_id}.dkr.ecr.${region}.amazonaws.com/${ecr_name}"
docker tag "${ecr_name}:${tag}" "${repository_uri}:${tag}"

# Login ECR
aws ecr get-login-password --profile "$profile" | \
  docker login --username AWS --password-stdin "$repository_uri"

# Push docker image
docker push "${repository_uri}:${tag}"
echo "Pushed image $ecr_name:${tag}"
