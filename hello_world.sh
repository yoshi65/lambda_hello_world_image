#!/bin/bash
#
# FileName: 	hello_world
# CreatedDate:  2021-05-29 17:43:34 +0900
# LastModified: 2021-05-29 18:28:01 +0900
#

set -eu

profile="default"
delete=false
ecr_name="dummy"
tag="latest"

usage_exit() {
  echo "usage: grep [-d] [-p profile] [-n ecr_name] [-t tag]"
  exit 1
}

while getopts p:n:t:dh OPT
do
    case $OPT in
        p)  profile=$OPTARG
            ;;
        p)  ecr_name=$OPTARG
            ;;
        t)  tag=$OPTARG
            ;;
        d)  delete=true
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

# Delete ecr
if "$delete"; then
  aws ecr delete-repository --profile $profile --repository-name $ecr_name --force
  echo "Deleted $ecr_name"
  exit
fi

# Set var
REGION=$(aws configure get region --profile $profile)
ACCOUNTID=$(aws sts get-caller-identity --profile $profile --output text --query Account)

# Create ECR
if ! aws ecr describe-repositories --profile=$profile | jq -r '.repositories[].repositoryName' | grep -qE $ecr_name; then
  aws ecr create-repository --profile $profile --repository-name $ecr_name
  echo "Created ecr $ecr_name"
else
  echo "ecr $ecr_name already exists"
fi

# Build docker image
docker build -t $ecr_name .

# Set docker tag
docker tag ${ecr_name}:${tag} ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com/${ecr_name}:${tag}

# Login ECR
aws ecr get-login-password --profile $profile | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com

# Push docker image
docker push ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com/${ecr_name}:${tag}
echo "Pushed image $ecr_name:${tag}"
