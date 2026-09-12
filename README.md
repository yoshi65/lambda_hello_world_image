# lambda_hello_world_image

Create an Amazon ECR repository and push a minimal AWS Lambda container image to it.
This is useful when infrastructure provisioning needs an image URI at creation time,
but the application image is not ready yet. The repository uses a small Python 3.13
Lambda handler that returns `hello world`.

## Prerequisites

- An AWS account and an AWS CLI v2 profile with a default Region configured.
- Docker 25.0.0 or later with the buildx plugin.
- Permission to create, describe, and delete ECR repositories and to push images.

The ECR repository must be in the same Region as the Lambda function that will use
the image. By default the script builds a `linux/amd64` image. Use `-a arm64` when
your Lambda function uses the ARM64 architecture.

## Create and push an image

```sh
git clone https://github.com/yoshi65/lambda_hello_world_image.git
cd lambda_hello_world_image
./hello_world.sh -n dummy
```

The script creates the ECR repository if it does not exist, enables scan on push,
builds the image with the Lambda-compatible platform/provenance settings, and pushes
the requested tag. It uses the `default` AWS CLI profile and the `latest` tag unless
you specify otherwise.

## Verify locally

Build and start the image with Docker, then invoke the Lambda Runtime Interface
Emulator endpoint:

```sh
docker buildx build --platform linux/amd64 --provenance=false --load -t lambda-hello:local .
docker run --rm --platform linux/amd64 -p 9000:8080 lambda-hello:local
```

In another terminal:

```sh
curl http://localhost:9000/2015-03-31/functions/function/invocations -d '{}'
```

The response contains a `200` status code and `hello world` message.

## Delete an ECR repository

```sh
./hello_world.sh -d -n dummy
```

`-d` permanently deletes the repository and all of its images.

## Options

```text
usage: ./hello_world.sh [-d] [-p profile] [-n ecr_name] [-t tag] [-a architecture]
    -d: Delete the ECR repository and every image in it
    -p: AWS CLI profile (default: default)
    -n: ECR repository name (default: dummy)
    -t: Image tag (default: latest)
    -a: Lambda architecture: amd64 or arm64 (default: amd64)
```
