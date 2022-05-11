# AWS ECR Setup guide

## What is AWS ECR?

The AWS Container Registry service is a managed container repository. ECR, like
the popular Dockerhub, supports both public and private repositories. We may
upload or pull images to ECR using the AWS CLI if needed.

It is not necessary to build containers and store them in your own private
repository since the Nova worker container images can be downloaded from our
public container registry.



## Create an AWS Container Registry (ECR)

For additional registry authentication methods, including the Amazon ECR
credential helper, see [Registry
Authentication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).
Also, refer to the AWS [ECR user
guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/get-set-up-for-amazon-ecr.html)
for tips and best practices for [creating the
repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html).



**On Shared Registry and Repositories**: The URL for your default registry is
`https://$MY_AWS_ACCOUNT_ID.dkr.ecr.$MY_REGION.amazonaws.com`, and by default,
your account has read and write access to the repositories in your default
registry. In the next step, we can log the registry using the `aws ecr` command. 

On **shared corporate accounts** you will be using a **shared Container
registry** and so you should consider prepending a unique name for the a
namespace to group the repository into a category, i.e. your own group.
For example, the repository name may be specified on its own (such as
`nginx-web-app`) or it can be prepended with a namespace to group the repository
into a category or user  (such as `armand/nginx-web-app`).



[### Create your ECR](#authenicate-to-ecr)

1. Retrieve an authentication token and authenticate your Docker client to your
   registry  using the `aws ecr` command:

```bash
MY_AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
MY_REGION=us-west-2

aws ecr get-login-password --region $MY_REGION | docker login \
   --username AWS \
   --password-stdin \
   $MY_AWS_ACCOUNT_ID.dkr.ecr.$MY_REGION.amazonaws.com
```

At the end of the output, you should see `Login Succeeded`!

### Test access to your ECR 

We can quickly test the ability to push images to our Private ECR from our
client machine

Take note of the image URIs in your private registry that is created from the
following steps. We will need it for when we push container images to the
registry



1. Create an ECR repository for your container images

```bash
MY_REGION=us-west-2
MY_REPO="armand/hello-world"

aws ecr create-repository --repository-name $MY_REPO --region $MY_REGION
```



2. If you do not have a test container image to push to ECR, you can download
   a simple container for testing, e.g.
   [armsultan/hello-world](https://hub.docker.com/r/armsultan/hello-world)

```bash
docker pull armsultan/hello-world
```

2. Get the image ID so we can tag it on the next step

```bash
docker images | grep hello-world
armsultan/hello-world    latest         15d53731c307        6 minutes ago       1.23MB
```

3. Tag the image with your registry URI

```bash
MY_AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
MY_REGION=us-west-2
MY_REPO="armand/hello-world"
MY_IMAGE_ID=15d53731c307

docker tag $MY_IMAGE_ID $MY_AWS_ACCOUNT_ID.dkr.ecr.$MY_REGION.amazonaws.com/$MY_REPO
```

4.  Your newly tagged image is now listed under `docker images`:

```bash
docker images | grep hello-world
664341837355.dkr.ecr.us-west-2.amazonaws.com/armand/hello-world   latest              15d53731c307        11 minutes ago      1.23MB
armsultan/hello-world                                             latest              15d53731c307        11 minutes ago      1.23MB
```

4. Push your tagged image to ECR

```bash
# you can get copy the docker image name from the last step 
docker push 664341837355.dkr.ecr.us-west-2.amazonaws.com/armand/hello-world 
```

5. Check it is up there using the AWS CLI

```bash
MY_REGION=us-west-2

aws ecr describe-repositories --region $MY_REGION | grep hello-world

# example output:
            "repositoryArn": "arn:aws:ecr:us-west-2:664341837355:repository/armand/hello-world",
            "repositoryName": "armand/hello-world",
            "repositoryUri": "664341837355.dkr.ecr.us-west-2.amazonaws.com/armand/hello-world",
```