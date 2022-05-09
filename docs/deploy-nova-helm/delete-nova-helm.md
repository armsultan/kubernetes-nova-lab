# Delete Nova from kuberntes

1. Remove Nova from your Kubernetes cluster using helm. This will remove the
`pod`(s), `deployment`, `services` (including default `LoadBalancer`), and
`namespaces`

    ```bash
    $ helm delete nova

    release "nova" uninstalled
    ```

All done. You have removed the Nova worker node and its assoicated kubernetes
components.

---

Go back to [Table of Contents](../../README.md)