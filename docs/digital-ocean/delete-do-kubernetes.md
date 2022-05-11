 doctl kubernetes cluster delete doks-armand-sfo2 
Warning: Are you sure you want to delete this Kubernetes cluster? (y/N) ? y
Notice: Cluster deleted, removing credentials
Notice: Removing cluster credentials from kubeconfig file found in "/home/vscode/.kube/config"
Notice: The removed cluster was set as the current context in kubectl. Run `kubectl config get-contexts` to see a list of other contexts you can use, and `kubectl config set-context` to specify a new one.


## Uninstall and Delete your DOKS cluster 

You can easily delete your EKS cluster at the end of the lab using the `doctl` tool

1. Find the correct EKS cluster to delete

    ```bash
    doctl kubernetes clusters list

    ID                                      Name                Region    Version        Auto Upgrade    Status     Node Pools
    cc1c935e-a14f-4485-9344-d54d107a1f33    doks-armand-sfo2    sfo2      1.22.8-do.1    false           running    doks-armand-sfo2-default-pool
    ```

1. Delete the cluster and its associated nodes with the following command,
   replacing `$MY` with your cluster name. 

    ```bash
    MY_EKS=doks-armand-sfo2

    eksctl delete cluster $MY_EKS
    ```

    Deleting you DOKS cluster will only take a few seconds, the clean up process
    will delete DO load balancers, other Kubernetes and DO objects currently
    in use.

---

We have successfully deleted our kubernetes cluster on DO - Go back to [Table of
Contents](../../README.md)