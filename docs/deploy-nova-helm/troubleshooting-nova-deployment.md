# Troubleshooting Nova Deployment in kubernetes

## <a id='loadBalancer-http80-only'></a> KNOWN ISSUE: Cannot Connecting from external through `LoadBalancer`

If you have issues with External connectivity, it could be because of the cloud
providers `loadBalancer` service health checking port 443 which does cause an
issue if not in use

To resolve this issue, try deploy another `loadBalancer` service,
only exposing and mapping port 80 with [this
manifest](deployments/nova/working-lb.yaml) provided:

1. Deploy `loadBalancer` service, only exposing and mapping port 80

    ```bash
    kubectl apply -f deployments/nova/working-lb.yaml
    ```

1. Check the `loadBalancer` service was deployed, in the example below it is
   seen as`service/test-nova-svc`

    ```bash
    kubectl get pods,deployments,services -n nova-ns
    NAME                            READY   STATUS    RESTARTS   AGE
    pod/nova-dpl-586fd467db-8zlg7   1/1     Running   0          40m

    NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/nova-dpl   1/1     1            1           40m

    NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                     AGE
    service/nova-svc        LoadBalancer   10.100.214.213   af3ddfb0668604150b92812938fadf8b-429243784.us-west-2.elb.amazonaws.com    443:31101/TCP,80:31574/TCP,1080:32260/TCP   40m
    service/test-nova-svc   LoadBalancer   10.100.32.172    a078ddbf4c95340ce8386d1fc774842e-1934362118.us-west-2.elb.amazonaws.com   80:31623/TCP                                31m 
    ```

1. Now try external connectivity via the `loadBalancer` `EXTERNAL-IP` using
   `curl`. First find the the external DNS name or Public IP address associated to the
   `loadBalancer` for the Nova (`test-nova-svc`) service.

    ```bash
    # Get External loadBalancer address
    EXTERNALIP=$(kubectl get services/test-nova-svc  -n nova-ns -o jsonpath='{.status.loadBalancer.ingress[*].hostname}')
    echo $EXTERNALIP
    # Optional: Get the IPv4 Address
    # NOVA_LB=$(dig +short $COFFEE_LB A |  awk 'NR==1')
    ```

1. Make a `curl` request and test external connectivity
    
    ```bash
    curl $EXTERNALIP

    Server name: moon-6cf747975f-cvj88
    Server address: 192.168.5.79:8080
    Status code: 200
    URI: /
    Cookies: 
    User-Agent: curl/7.74.0
    Date: 10/May/2022:19:00:33 +0000
    Request ID: a61d47ae7b2c64b4796dd8275ffdedce
    ```
------


## <a id='insufficient-resources'></a> Nova pods are `pending` due to `Insufficient memory` or `Insufficient CPU`


By default, the deployment defines resources requests and limits. While this is
a kubernetes administration best pratice, if you are testing the Nova
deployment, understandably, you could be deploying on low resourced kubernetes
clusters (e.g. [Digital
Ocean's](https://docs.digitalocean.com/products/kubernetes/) smallest and Basic
cluster size).  In the case of `Insufficient memory` or  `Insufficient CPU`
errors, your pods will be stuck in a If pods are `pending` state. 

The default `resources` `requests` and `limits` defined on the Nova
ADC Worker pod is seen in the snippet below:

  ```yaml
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 200m
      memory: 1Gi
  ```


If pods are `pending` due to `Insufficient memory` or `Insufficient CPU` we can
set lower resource requirements:

### Using `kubectl set resource` on-the-fly

1. We can set the resource requests and limits of the Deployment using `kubectl`

    ```bash
    kubectl set resources deployment nova-dpl -n nova-ns \
       --limits cpu=300m,memory=2Gi \
       --requests cpu=50m,memory=200Mi
    
    deployment.apps/nova-dpl resource requirements updated
    ```

1. Check the deployment

    ```bash
    kubectl get pods,deployments,services -o wide -n nova-ns
    NAME                            READY   STATUS    RESTARTS   AGE   IP             NODE                   NOMINATED NODE   READINESS GATES
    pod/nova-dpl-59c785889b-8wq9w   1/1     Running   0          38s   10.244.1.206   pool-gl450ovty-u4m3n   <none>           <none>

    NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                       SELECTOR
    deployment.apps/nova-dpl   1/1     1            1           44m   nova-nvc     novaadc/nova-client:latest   app=nova-nvc,deployment=nova-dpl

    NAME               TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                     AGE   SELECTOR
    service/nova-svc   LoadBalancer   10.245.200.88   161.35.240.12   443:30306/TCP,80:30625/TCP,1080:30631/TCP   44m   app=nova-nvc,deployment=nova-dpl
    ```

### Make changes in a yaml manifest then apply

Alternately you can record these changes in a yaml manifest and apply changes in
`kubectl` also:

1. Export the Nova deployment (`nova-dpl`)  manifest to a editable `yaml` file

    ```bash
    kubectl get deployment.apps/nova-dpl -n nova-ns -oyaml > nova-less-resources.yaml
    ```

1. Edit the yaml and lower the resource requests, i.e.

    **Change:**
    ```yaml
            resources:
              limits:
                cpu: 300m
                memory: 2Gi
              requests:
                cpu: 200m     # <--Edit this
                memory: 1Gi   # <--Edit this
    ```
    **To:**
    ```yaml
            resources:
              limits:
                cpu: 300m
                memory: 2Gi
              requests:
                cpu: 50m
                memory: 200Mi
    ```

1. Apply changes define in the manifest file using `kubectl apply`

    ```bash
    kubectl apply -f nova-less-resources.yaml
    ```

1. Check the deployment

    ```bash
    kubectl get pods,deployments,services -o wide -n nova-ns
    NAME                            READY   STATUS    RESTARTS   AGE   IP             NODE                   NOMINATED NODE   READINESS GATES
    pod/nova-dpl-59c785889b-8wq9w   1/1     Running   0          38s   10.244.1.206   pool-gl450ovty-u4m3n   <none>           <none>

    NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                       SELECTOR
    deployment.apps/nova-dpl   1/1     1            1           44m   nova-nvc     novaadc/nova-client:latest   app=nova-nvc,deployment=nova-dpl

    NAME               TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                     AGE   SELECTOR
    service/nova-svc   LoadBalancer   10.245.200.88   161.35.240.12   443:30306/TCP,80:30625/TCP,1080:30631/TCP   44m   app=nova-nvc,deployment=nova-dpl
    ```

## Discovery our DNS service addresses 


1. Deploy a utility container, `network-tools`, pod to test connectivity to our services via its `ClusterIP`

  ```bash
  # Use this manifest to create our dnsutil Pod:
  kubectl apply -f deployments/tools/network-tools.yaml

  pod/network-tools created

  # Verify its status
  kubectl get pods network-tools

  NAME                READY     STATUS    RESTARTS   AGE
  network-tools   1/1       Running   0          <some-time>
  ```

2. A CLUSTER-IP will exist if you have "normal" services. Find this internal IP
   address and text connectivity from inside the kubernetes cluster using `curl`

  ```bash
  # moon-svc 
  moon_cluster_ip=$(kubectl get services/moon-svc -n solar-system | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  # sun-svc 
  sun_cluster_ip=$(kubectl get services/sun-svc -n solar-system | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  # moon-svc
  kubectl exec -i -t network-tools -- curl http://$moon_cluster_ip -I

  # sun-svc
  kubectl exec -i -t network-tools -- curl http://$sun_cluster_ip -I
  ```
---

## Test nova 

We can inspect the Nova deployment in closer detail by inspecting the output of the
deployment using `kubectl describe` or yaml output:

  ```bash
  k describe deployment nova-dpl -n nova-ns
  ```

  ```bash
  k get deployment nova-dpl -n nova-ns -oyaml
  ```

  For example, we can see the resource limits
  ```
  Note: 
  ```yaml
          resources:
            limits:
              cpu: 300m
              memory: 2Gi
            requests:
              cpu: 200m
              memory: 1Gi
  ```   

## Inspect CPU and memory usage on your Kubernetes Cluster

We can inspect the CPU and memory usage in various ways. one way is using `metrics-server`.
If you do not have that install, follow the install instructions from the offical github project page, 
[metrics-server](https://github.com/kubernetes-sigs/metrics-server)

1. Deploy `metrics-server` using `helm` or using yaml manifest

  **Using Helm:**
  ```bash
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm upgrade --install metrics-server metrics-server/metrics-server
  ```

  **Or via yaml:**
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```

1. Confirm that the Kubernetes `metrics-server` has been deployed successfully

  ```bash
  kubectl get deployment metrics-server --watch
  NAME             READY   UP-TO-DATE   AVAILABLE   AGE
  metrics-server   1/1     1            1           36s
  ```

1. Now you can run `kubectl top node` or `kubectl top pod` to see resource usage

  ```bash
  kubectl top node
  NAME                   CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
  pool-gl450ovty-u4m33   38m          4%     919Mi           58%       
  pool-gl450ovty-u4m38   42m          4%     955Mi           60%       
  pool-gl450ovty-u4m3n   28m          3%     889Mi           56%       
  ```

Hope these Troubleshooting Guides have been useful!
---

Go back to [Table of Contents](../../README.md)