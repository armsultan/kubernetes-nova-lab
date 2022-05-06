# Snapt Nova for Kubernetes lab

**WIP:** Collection of exercises to get acquainted with Kubernetes and exposing
services realiably and securely using [Snapt Nova](https://www.snapt.net/platforms/nova-adc)

## Lab Guide

1. Setup our client "jump host" using VS code Development Containers
   1. [Get started with development Containers in Visual Studio Code](docs/dev-container/lab-setup-using-dev-container.md)

1. Deploy a Kubernetes cluster in the cloud (Amazon Web Services (AWS))
   1. [Create our a AWS EKS Kubernetes cluster](docs/aws/aws-cli-eks-setup-guide.md)

1. Deploy Sample Application
   1. [Deploy our Sample Applications](docs/deploy-sample-application/deploy-sample-application.md)
   1. An Important sidebar: [Service Discovery on "Normal" vs "Headless" services](docs/deploy-nova-helm/service-discovery-normal-vs-headless-services.md
   1. (docs/deploy-nova-helm/configure-nova-backends.md)
## Clean up after lab completion

1. Clean up - Delete out Kubernetes cluster in the cloud (Amazon Web Services (AWS))
   1. [Delete our AWS EKS Kubernetes cluster](docs/aws/delete-eks-cluster.md)
