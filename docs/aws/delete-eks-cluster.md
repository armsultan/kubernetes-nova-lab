
## Uninstall and Delete your EKS cluster 

You can easily delete your EKS cluster at the end of the lab using the `eksctl` tool

1. Find the correct EKS cluster to delete

    ```bash
    $ eksctl get cluster
    
    2022-05-09 14:55:57 [ℹ]  eksctl version 0.96.0
    2022-05-09 14:55:57 [ℹ]  using region us-west-2
    
    NAME                    REGION          EKSCTL CREATED
    eks-armand-uswest2      us-west-2       True

    ```

1. Delete the cluster and its associated nodes with the following command,
   replacing `$MY` with your cluster name. 

    ```bash
    MY_EKS=eks-armand-uswest2
    eksctl delete cluster $MY_EKS
    ```

    Deleting you EKS cluster will take some time (~10min), the clean up process
    will delete AWS load balancers, other Kubernetes and AWS objects currently
    in use.

---

We have successfully deleted our kubernetes cluster on EKS - Go back to [Table of Contents](../../README.md)