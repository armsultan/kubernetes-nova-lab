

1. Lets first update our **sun** and **moon** deployment replicas to four each,
   this way we can see up rolling updates in action
    
    ```bash
    # Scale replicas of sun and moon to four pods each
    kubectl scale deployments/moon --replicas=4 -n solar-system
    kubectl scale deployments/sun --replicas=4 -n solar-system

    # Confirm Pods in the deployment have scaled
    kubectl get pods,deployments,services -n solar-system
    ```
### On-the-fly update using `kubectl set image`

1. We can update the our simple applications, **sun** and **moon** Deployments,
   currently using a text based application (`armsultan/test-page:text-nonroot`)
   to a fancy application (`armsultan/solar-system:sun-nonroot` and
   `armsultan/solar-system:moon-nonroot`) by updating the images in the deployment
   using `kubectl`
   
   The `kubectl set image` command updates the container image of the
   Deployment's Pods one at a time.

    ```bash
    # Update sun
    kubectl set image deployment sun -n solar-system \
            armsultan/solar-system:sun-nonroot

    # Update moon
    kubectl set image deployment moon -n solar-system \
            armsultan/solar-system:moon-nonroot
    ```
### On-the-fly update using `kubectl edit`

1. *Alternatively*, you can edit the **sun** Deployment and change the
   `.spec.template.spec.containers[0].image` from
   `armsultan/test-page:text-nonroot` to `armsultan/solar-system:sun-nonroot`,
   and edit the **moon** Deployment and change the
   `.spec.template.spec.containers[0].image` from
   `armsultan/test-page:text-nonroot` to `armsultan/solar-system:moon-nonroot`

    **Edit sun**
    ```bash
    kubectl edit deployment/sun -n solar-system
    ```

    **Edit moon**
    ```bash
    kubectl edit deployment/moon -n solar-system
    ```

### Apply an updated deployment manifest `yaml`

1. *Alternatively*, you can edit the **sun** and **moon** Deployment manifest and change
   `.spec.template.spec.containers[0].image` from
   `armsultan/test-page:text-nonroot` to `armsultan/solar-system:sun-nonroot` for **sun**,
   and change the `.spec.template.spec.containers[0].image` from
   `armsultan/test-page:text-nonroot` to `armsultan/solar-system:moon-nonroot` for **moon**.
   You then can apply changes using `kubectl`. 

    The following will update the **sun** and **moon** deployments using the [provided
    manifest](../deploy-sample-application/deploy-fancy-application.md)

    ```bash
    kubectl apply -f deployments/fancy-app/fancy-app.yaml
    ```
### Check update and rollout status

1. To see the rollout status, run:

    ```bash
    # Check rollout status of sun
    kubectl rollout status deployment/sun -n solar-system

    Waiting for deployment "moon" rollout to finish: 3 out of 4 new replicas have been updated...
    deployment "sun" successfully rolled out

    # Check rollout status of moon
    kubectl rollout status deployment/moon -n solar-system

    Waiting for deployment "moon" rollout to finish: 2 out of 4 new replicas have been updated...
    deployment "moon" successfully rolled out
    ```

1. You can also see the pods 
    ```bash
    kubectl get pods -n solar-system
    ```

1. Get more details on your updated Deployment

    **sun deployment**
    ```bash
    # See details for sun
    kubectl describe deployment sun -n solar-system

    # Or specificly see the image used
    kubectl describe deployment sun -n solar-system | grep Image
    ```
    
    **and moon deployment**
    ```bash
    # See details for sun
    kubectl describe deployment moon -n solar-system

    # Or specificly see the image used
    kubectl describe deployment moon -n solar-system | grep Image
    ```

1.  Find the the external DNS name or Public IP address associated to the
   `loadBalancer` for the Nova (`nova-srv`) service.

    ```bash
    # Get External loadBalancer FQDN 
    EXTERNALIP=$(kubectl get services/nova-svc -n nova-ns -o jsonpath='{.status.loadBalancer.ingress[*].hostname}')
    #OR
    # Get External loadBalancer IP address
    EXTERNALIP=$(kubectl get services/nova-svc -n nova-ns -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
    
    # Print that out
    echo $EXTERNALIP
    # Optional: Get the IPv4 Address
    # NOVA_LB=$(dig +short $COFFEE_LB A |  awk 'NR==1')
    ```

1. Now run a `curl` command to test access from *outside* the kubernetes
   cluster, in a terminal or web browser on you your client machine 

    ```bash
    # Using curl 
    curl http://$EXTERNALIP

    # Using a web browser - get the DNS or IP address and enter into your web browser
    echo $EXTERNALIP
    ad95405e2bbfc4e97af5866540135fe2-1347037189.us-west-2.elb.amazonaws.com
    ```