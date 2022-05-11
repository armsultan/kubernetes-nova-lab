# Digital Ocean Kubernetes (DOKS) setup guide

This guide offers Cloud managed Kubernetes alternative. Follow this guide to
create [DigitalOcean Kubernetes
(DOKS)](https://docs.digitalocean.com/products/kubernetes/how-to/create-clusters/).


## Prerequisites
To follow this guide, you need to:

 * [`doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/), the DigitalOcean command-line tool (included in the Development Container)
 * [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/), the Kubernetes command-line tool (included in the Development Container)
 * A [DigitalOcean account](https://cloud.digitalocean.com/registrations/new) with a Read/Write **access token**

## What is Digital Ocean Kubernetes (DOKS)?

DigitalOcean Kubernetes (DOKS) is a managed Kubernetes service that allows you
to set up Kubernetes clusters without having to deal with the control plane or
containerized infrastructure. Clusters are compatible with basic Kubernetes
toolchains and work seamlessly with DigitalOcean Load Balancers and block
storage volumes.

## Digital Ocean Regions, and naming convention suggestions

1. Check out Digital Ocean's [Regional Availability
   Matrix](https://docs.digitalocean.com/products/platform/availability-matrix/),
   and under "[Other Product
   Availability](https://docs.digitalocean.com/products/platform/availability-matrix/#other-product-availability)"
   you can see where managed Kubernetes is supported closest to you and meets
   your needs. Check out this [Digital Ocean latency
   test](https://cloudpingtest.com/digital_ocean)!
1. Consider creating a new
   [Project](https://docs.digitalocean.com/products/projects/) to contain your
   Kubernetes cluster,  and tagging convention to organize your cloud assets to
   support user identification of shared subscriptions. We discuss this in
   "[Setup DOKS](#setup-doks)"


## Digital Ocean's `doctl` CLI Basic Settings (Configuration and Credential File Settings)

We will use `doctl`, Digital Ocean's Command Line Interface (CLI) installed on
your client machine or development container to provision and manage our DOKS.
For more tips on using the `doctl` cli tool, see [Command Line Interface (CLI)
Reference for doctl](https://docs.digitalocean.com/reference/doctl/reference/)

**Note:** The `doctl auth init` commands to setup your doctl cli client needs to
be run the first time or each time your development container is built. A
personal access token with `READ`/`WRITE` Scope is required

1. Configure the client using `doctl auth init`

   ```bash
   # Access your "Personal Access token" from API > Applications & API in
   # the Digital Ocean web portal

   doctl auth init

   Please authenticate doctl for use with your DigitalOcean account. 
   You can generate a token in the control panel at https://cloud.digitalocean.com/account/api/tokens

   Enter your access token: [ENTER YOUR PERSONAL TOKEN]
   Validating token... OK
   ```

We can inspect the `doctl` config file at any time. It is located on the dev
container under `~/.config/doctl/config.yaml`

1. Check `~/.config/doctl/config.yaml` file

   ```bash
   bat ~/.config/doctl/config.yaml

   cat ~/.config/doctl/config.yaml | grep access-token
   ```

1. You can validate that `doctl` is working

   ```bash
   doctl account get

   Email             Droplet Limit    Email Verified    UUID                                    Status
   your@email.com    50               true              XXXXXXXX-Xxxx-XXXX-xxxx-XXXXXXXXXXxx    active
   ```

1. Let's try our first `doctl` CLI command. Get a list of all of the Regions that are
   enabled for your account. Note the `Available` `true`|`false` status

   ```bash
   doctl compute region list
   ```

## Deploy a Kubernetes Cluster with AWS CLI

You can deploy a cluster using multiple methods. Common methods for AWS include
using the
[Digital Ocean's Control Panel](https://docs.digitalocean.com/products/kubernetes/how-to/create-clusters/)
or [`doctl`](https://docs.digitalocean.com/products/app-platform/references/command-line/)
CLI.

For this lab we will use `doctl`.

### Setup Ocean Kubernetes (DOKS) {#setup-doks}

For this lab, we will be creating an Digial Ocean managed Kubernetes cluster.
Consider a naming and tagging convention to organize your cloud assets to
support user identification of shared subscriptions. 

The machine size options of Kubernetes nodes to use is also a consideration
since by default, each nova container will have a`resources` `requests` of
`cpu: 200m` and `memory: 1Gi`


We wil be deploying the default 3 node cluster (`--count=3`) and
non-highly-available control plane (`--ha=false`). For other options see the
[`doctl`
reference](https://docs.digitalocean.com/reference/doctl/reference/kubernetes/cluster/create/)

#### Naming example

I am located in Denver, Colorado; I will opt to use the Datacenter region
`sfo2` is based in San Francisco. I could also use the following naming
convention:

```bash
<Asset_type>-<your_id_yourname>-<location>-<###>
```

So for my DOKS Cluster, I will deploy in San Francisco, i.e., `sfo2`, (`sfo1`
was marked unavailable) and will name my Cluster `doks-armand-sfo1-a` or just
`doks-armand-sfo1` since I don't intend to have more than one EKS deployment in
this region

I will also use the tag `user=armand` to further identify my asset on our shared
account


1. Review the Machine size options of Kubernetes nodes to use.

   ```bash
   doctl kubernetes options sizes
   ```

   I will select `s-2vcpu-4gb` to better accomidate the resource requirements
   for this lab setup

1. Use `doctl` to create a Sandbox DOKS cluster with some options in a single
   command. **This will take a while** (Over 10 minutes)

   ```bash
   MY_REGION=sfo2
   MY_DOKS=doks-armand-sfo2
   MY_NAME=armand

   # doctl kubernetes cluster create <name> [flags]
   doctl kubernetes cluster create \
      $MY_DOKS \
      --region $MY_REGION \
      --tag $MY_NAME \
      --size s-2vcpu-4gb
   ```
   An example output of a completed deployment may look like this:

   ```bash
   #...
   .....................................................................................
   Notice: Cluster created, fetching credentials
   Notice: Adding cluster credentials to kubeconfig file found in "/home/vscode/.kube/config"
   Notice: Setting current-context to do-sfo2-doks-armand-sfo2
   ID                                      Name                Region    Version        Auto Upgrade    Status     Node Pools
   cc1c935e-a14f-4485-9344-d54d107a1f33    doks-armand-sfo2    sfo2      1.22.8-do.1    false           running    doks-armand-sfo2-default-pool
   ```

1. Run the following command to check your DOKS clusters provisioned, along with
   any existing kubernetes clusters in your DO organization

   ```bash
   doctl kubernetes cluster list

   ID                                      Name                Region    Version        Auto Upgrade    Status     Node Pools
   b095b788-67f5-4bd2-a765-6b4d56b8e6c0    doks-armand-sfo2    sfo2      1.22.8-do.1    false           running    worker-pool doks-armand-sfo2-pool-2 doks-armand-sfo2-pool-3
   ```

1. The`doctl kubernetes cluster create` process should have already adding the
   cluster credentials to `kubeconfig` file. We can confirm this using `kubectl`
   commands and easily change between context if you are managing multiple
   Kubernetes clusters

   ```bash
   # Get a list of Kubernetes clusters in your local Kube config
   kubectl config get-clusters

   NAME
   do-sfo2-doks-armand-sfo2

   # Set context to our DOKS cluster
   kubectl config set-context do-sfo2-doks-armand-sfo2

   # Check which context you are currently targeting
   kubectl config current-context

   # Get Nodes in the target Kubernetes cluster
   kubectl get nodes

   NAME                                  STATUS   ROLES    AGE     VERSION
   doks-armand-sfo2-default-pool-cw9v2   Ready    <none>   7m54s   v1.22.8
   doks-armand-sfo2-default-pool-cw9vl   Ready    <none>   7m44s   v1.22.8
   doks-armand-sfo2-default-pool-cw9vt   Ready    <none>   7m49s   v1.22.8
   ```

---

We have successfully deployed our kubernetes cluster - Go back to [Table of Contents](../../README.md)