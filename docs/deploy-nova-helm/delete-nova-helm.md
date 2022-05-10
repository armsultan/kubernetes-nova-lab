# Delete Nova from kuberntes

Remove Nova from your Kubernetes cluster using helm. This will remove everything
in the namespace (default is `nova-ns`) Nova is deployed, including all the
`pod`(s), `deployment`, `services` (including default `LoadBalancer`) that was
deployed by helm, the `namespace` will also be deleted

1. Remove Nova from your Kubernetes cluster using helm

    ```bash
    $ helm delete nova

    release "nova" uninstalled
    ```

All done. You have removed the Nova worker node and its assoicated kubernetes
components.

---

Go back to [Table of Contents](../../README.md)