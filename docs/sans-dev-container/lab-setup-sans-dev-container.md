# Lab Setup - *Not using* development Containers in Visual Studio Code

We recommend using our development Container in Visual Studio Code for this lab
exercise for convenience which will include all the tools required to follow the
lab. See the [Lab Setup Guide for using development Containers in Visual Studio
Code](../dev-container/Lab-setup-using-dev-container.md) your client machine

**Continue on to setup prerequsite tools to run the lab *without* development
Containers in Visual Studio Code**

## Prerequisites tools

In summary, you need:

 * [kubectl]((https://kubernetes.io/docs/tasks/tools/install-kubectl/)
 * [Helm](https://helm.sh/docs/intro/install/)
 * [AWS CLI tool](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
 * [eksctl CLI tool](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
 * Other useful linux/unix command line tools:
    * [`jq`](https://stedolan.github.io/jq/)
    * [`bat`](https://github.com/sharkdp/bat)
    * [`tree`](https://linux.die.net/man/1/tree)
    * [`curl`](https://curl.se/download.html)
    * [`httpie`](https://httpie.io/)

### kubectl

1. Make sure you have the Kubernetes command-line tool, `kubectl`, to run
   commands against Kubernetes clusters. If you have not go this ready  **See
   [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)**

  You can use kubectl to deploy applications, inspect and manage cluster
  resources, and view logs. For a complete list of `kubectl` operations, see
  [Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/).

  For example, installing on linux:

  ```bash
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin/kubectl
  ```


### Helm

1. See [Helm install instructions](https://helm.sh/docs/intro/install/). For
   example, installing on linux:

  ```bash
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  ```

### kubectl

1. See [AWS CLI tool install instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html). For
   example, installing on linux:

  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```

### kubectl


1. See [eksctl CLI tool install instructions](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html. For
   example, installing on linux:

  ```bash
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  eksctl version
  ```

### Other tools

1. We will use popular command line tools in linux/unix in this lab. For
   example, installing on ubuntu linux:

   ```bash
   sudo apt-get install -y bat curl httpie jq httpie
   ```

We are now ready to run the lab! - Go back to [Table of Contents](../../README.md)
