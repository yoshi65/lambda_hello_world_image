# lambda_hello_world_image

To create and push ecr and hello world image as dummy image easily and quickly

## Why

We create lambda more easily, when managing lambda using ecr by terraform, if we can use dummy image (We cannot use public image, currently.). 

- If not so, we need to create lambda after creating ecr.
- If so, we can create both lambda and ecr as the same time.

# How to use
```sh
git clone https://github.com/yoshi65/lambda_hello_world_image.git
cd lambda_hello_world_image
./hello_world.sh
```

If you need to delete this
```sh
./hello_world.sh -d
```

# Option
```sh
usage: grep [-d] [-p profile] [-n ecr_name] [-t tag]
    -d: Delete ecr
    -p: Set AWS profile (default: default)
    -n: Set ecrECR name (default: dummy)
    -t: Set image tag (default: latest)
```
