
## Uninstall and Delete your EKS cluster 

You can easily delete your EKS cluster at the end of the lab using the `eksctl` tool

1. Delete the cluster and its associated nodes with the following command,
   replacing `$MY` with your cluster name. 

    ```bash
    $MY_EKS=eks-armand-uswest2
    eksctl delete cluster $MY_EKS
    ```

We have successfully deleted our kubernetes cluster on EKS - Go back to [Table of Contents](../../README.md)