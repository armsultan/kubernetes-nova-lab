WIP:

## Troubleshooting

If the Pod is stuck in a `pending`  state, we can troubleshoot with the following:

```bash
kubectl get events -n nova-ns
```

```
k logs [pod name] -n nova-ns
```

```
k describe [pod name] -n nova-ns
```

If pods are `pending` due to `Insufficient memory` or `Insufficient CPU`

we can inspect the CPU and memory usage in various ways. one way is using metrics-server.
If you do not have that install, follow the install instructions from the offical github project page, 
[metrics-server](https://github.com/kubernetes-sigs/metrics-server)

For example:

Using Helm:
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server

```
Or via yaml:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Confirm that the Kubernetes Metrics Server has been deployed successfully and is available by entering:

```bash
kubectl get deployment metrics-server --watch
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           36s
```
now run `kubectl top node` or `kubectl top pod`
```
kubectl top node
NAME                   CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
pool-gl450ovty-u4m33   38m          4%     919Mi           58%       
pool-gl450ovty-u4m38   42m          4%     955Mi           60%       
pool-gl450ovty-u4m3n   28m          3%     889Mi           56%       
```

Less resources:

1. export the deployment manifest

```bash
kubectl get deployment.apps/nova-dpl -n nova-ns -oyaml > nova-less-resources.yaml
```

2. edit the yaml and lower the resource requests, i.e.

**Change:**
```yaml
        resources:
          limits:
            cpu: 300m
            memory: 2Gi
          requests:
            cpu: 200m
            memory: 1Gi
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

3. Apply changes

```bash
kubectl apply -f nova-less-resources.yaml
```

4. Check the deployment
```
kubectl get pods,deployments,services -o wide -n nova-ns
NAME                            READY   STATUS    RESTARTS   AGE   IP             NODE                   NOMINATED NODE   READINESS GATES
pod/nova-dpl-59c785889b-8wq9w   1/1     Running   0          38s   10.244.1.206   pool-gl450ovty-u4m3n   <none>           <none>

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                       SELECTOR
deployment.apps/nova-dpl   1/1     1            1           44m   nova-nvc     novaadc/nova-client:latest   app=nova-nvc,deployment=nova-dpl

NAME               TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                     AGE   SELECTOR
service/nova-svc   LoadBalancer   10.245.200.88   161.35.240.12   443:30306/TCP,80:30625/TCP,1080:30631/TCP   44m   app=nova-nvc,deployment=nova-dpl
```

## Finding backend


we can deploy a utility container, network-tools, pod to test requests to our services via it's ClusterIP
```bash
# Use this manifest to create our dnsutil Pod:
kubectl apply -f deployments/tools/network-tools.yaml

pod/network-tools created

# Verify its status
kubectl get pods network-tools

NAME                READY     STATUS    RESTARTS   AGE
network-tools   1/1       Running   0          <some-time>
```

# moon-svc 
moon_cluster_ip=$(kubectl get services/moon-svc -n solar-system | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

# sun-svc 
sun_cluster_ip=$(kubectl get services/sun-svc -n solar-system | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

# moon-svc
kubectl exec -i -t network-tools -- curl http://$moon_cluster_ip -I

# sun-svc
kubectl exec -i -t network-tools -- curl http://$sun_cluster_ip -I

---

## Test nova 



We can inspect the deployment in closer detail by inspecting the output of the
deployment using `kubectl describe` or yaml output:

```bash
k describe deployment nova-dpl -n nova-ns
```

```bash
k get deployment nova-dpl -n nova-ns -oyaml
```

For example, we can see the reource limits
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

```


--------------------------------------------------------------------------------

## Troubleshooting

1. A Nova deployment may have one or more of the following symtpoms:

   * `pod` is stuck at `STATUS Pending` 
   * `deployment` is not 100% ready, e.g. `READY 0/1`
   * `LoadBalancer` is stuck on`EXTERNAL-IP <pending>`

  ```bash
  $ kubectl get pods,deployments,services -n nova-ns

  NAME                            READY   STATUS    RESTARTS   AGE
  pod/nova-dpl-574fb977d6-jzq9f   1/1     Pending   0          3m11s

  NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
  deployment.apps/nova-dpl   0/1     1            0           3m11s

  NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                     AGE
  service/nova-svc   LoadBalancer   10.245.200.88   <pending>     443:30306/TCP,80:30625/TCP,1080:30631/TCP   3m11s
  ```
  


The Kubernetes dashboard is another way to quicky understand reasons for errors:

[kubernetes dashboard](media/image3.png)

A Namespace following the following convention: $release_name-nova-ns
A Deployment with a single replica using the novaadc client container
A Service with type LoadBalancer

1. The Nova Node is now configured and this can be confirmed in the Nova Controller

[Nova Node is configured](media/image4.png)


2. Check eaccess to the LoadBalancer EXTERNAL-IP in web browser or terminal

```
curl http://161.35.240.12 
```