# Snapt Nova for Kubernetes lab

**WIP:** Collection of exercises to get acquainted with Kubernetes and exposing
services realiably and securely using [Snapt Nova](https://www.snapt.net/platforms/nova-adc)

## Basic Setup

1. Setup our client "jump host" using Development Containers in Visual Studio Code
   1. [Get started with development Containers in Visual Studio Code](docs/dev-container/Lab-setup-using-dev-container.md)

1. Deploy a Kubernetes cluster in the cloud
   1. **Recommended:** [Create an Amazon Web Services (AWS) EKS Kubernetes cluster](docs/aws/aws-cli-eks-setup-guide.md)
   1. *Alternative:* [Create a Digital Ocean Kubernetes cluster (DOKS)](docs/digital-ocean/do-kubernetes-setup-guide.md)

1. Deploy Sample Application
   1. [Deploy our Sample Applications](docs/deploy-sample-application/deploy-sample-application.md)
   1. [Service Discovery with "Normal" vs "Headless" services](docs/deploy-sample-application/service-discovery-normal-vs-headless-services.md)

1. Deploy Nova for Kubernetes
   1. [Configure simple HTTP load Balancing in Nova](docs/deploy-nova-helm/configure-simple-http-load-balancing-in-nova.md)
   1. [Deploy Nova for Kubernetes using Helm](docs/deploy-nova-helm/deploy-nova-helm.md)

1. Client-side testing, connectivity applications exposed by Nova for Kubernetes
   1. [Test connectivity to our applications](docs/deploy-nova-helm/test-connectivity-to-applications.md)

1. Scaling Nova Workers and ADC clusters in action
   1. [Scaling Nova Workers](docs/deploy-nova-helm/scaling-nova.md)

## Demos 
   1. [Deploy a Fancier Application](docs/deploy-sample-application/deploy-fancy-application.md)

## Troubleshooting Nova 
   1. [Troubleshooting](docs/deploy-nova-helm/troubleshooting-nova-deployment.md)

## Clean up after lab completion

1. Delete the Nova deployment in kubernetes 
   1. [Delete Nova deployment using helm](docs/deploy-nova-helm/delete-nova-helm.md)

1. Clean up - Delete your Kubernetes cluster in the cloud (AWS) when you are done testing
   1. [Delete our AWS EKS Kubernetes cluster](docs/aws/delete-eks-cluster.md)
   1. [Delete our Digital Ocean Kubernetes cluster](docs/digital-ocean/delete-do-kubernetes.md)

   