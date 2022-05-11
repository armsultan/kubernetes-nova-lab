# Service Discovery on "Normal" vs "Headless" services

Before we can create our backend groups for our **sun** and **moon**
applications in Nova, it is important to cover important DNS for Services and
Pods concepts first, and point out "Normal" vs "Headless" services and how that
affects how Nova Load Balancers the pods directy or not.

## Whats a Service to a Pod?

A Service is an abstraction that defines a logical set of identical Pods running
somewhere in your cluster that provides the same functionality. Every Service
has a distinct IP address, also known as `clusterIP`, and when created that IP
address will not change while for the lifetime of the Service.  A consistent DNS
name is also provided and can be used to reach the service rather than IP
address, thanks to Kubernetes, which generates DNS records for services and
pods.

Pods can be configured to talk to the Service to which it is logically tied, and
know that communication to the Service will be automatically load-balanced out
(randomly) to some pod that is a member of the Service.

## "Normal" vs "Headless" service

"Normal" (not headless) Services are assigned a DNS A or AAAA record, depending
on the IP family of the service, for a name of the form
`my-svc.my-namespace.svc.cluster-domain.example`. This resolves to the cluster
IP of the Service.

A "Headless" service on the other hand does not have `clusterIP` and Services
are also assigned a DNS A or AAAA record, just like a "Normal" (not headless)
service, for a name of the form
`my-svc.my-namespace.svc.cluster-domain.example`.  However, and very important:
Unlike normal Services, this resolves to the set of IPs of the pods selected by
the Service. Clients are expected to consume the set or else use standard
round-robin selection from the set.

To populate and track its backend group members, Nova for Kubernetes (today, in
May 2022) uses DNS service discovery. It is optimal to directly load balance and
proxy the pods as opposed to a service via its `clusterIP` as an intermediary,
therefore you must configure your Services to be of the "Headless" type, i.e. no
`clusterIP`, this will allow responses to the DNS queries to return all the IPs
of the pods selected

## DNS service discovery in action

Let's check out DNS service discovery in action on "Normal" Services and
"Headless" Services.

The standard DNS name for a service is
`my-svc.my-namespace.svc.cluster-domain.example`, where `my-svc` is the service
name and `my-namespace`, the namespace. This DNS name resolves to the
`clusterIP` in a "Normal" Services or return a set of IP addresses of all the
pods in a "Headless" Services.

### Use a simple network utility Pod to test our DNS

1. Use
   [**network-tools**]https://github.com/armsultan/docker-network-tools),
   a utility Docker network troubleshooting container to run a DNS lookup. First
   deploy the network utility pod

      ```bash
      # Use this manifest to create the network utility Pod:
      kubectl apply -f deployments/tools/network-tools.yaml
      pod/network-tools created

      # verify it's status
      kubectl get pods network-tools

      NAME           READY    STATUS    RESTARTS   AGE
      network-tools   1/1     Running   0          37s
      ```

### Run DNS checks on "Normal" Service

In a previous excerise,[Deploy our Sample
Applications](../deploy-sample-application/deploy-sample-application.md) we
deployed our sun and moon applications with a "normal" service. We used [this
manifest file](../../deployments/simple-app/simple-app-service.yaml) which
**does not** explicitly se `clusterIP: None`

1.  Now that the `network-tools` pod is running, you can use `kubectl exec` to do a `nslookup` or
    `dig` or in that environment. If you see something like the following when
    querying for the **sun** service, DNS is working correctly.

      ```bash
      # Find out Sun Application
      kubectl exec -i -t network-tools -- nslookup  _http._tcp.sun-svc.solar-system.svc.cluster.local

      Server:         10.100.0.10
      Address:        10.100.0.10#53

      Name:   _http._tcp.sun-svc.solar-system.svc.cluster.local
      Address: 10.100.130.214
      ```
      We have confirmed the following: 
      * The Service Discovery Address "`_http._tcp.sun-svc.solar-system.svc.cluster.local`" resolves to the
      `clusterIP` address of `10.100.130.214` as it is a "normal" service
      * `kube-dns` is the internal kubernetes DNS and is available on `10.100.0.10:53`
  
1.  Run `kubectl exec` to do a `nslookup`once again for the **moon** service

      ```bash
      # Find out Moon Application
      kubectl exec -i -t network-tools -- nslookup  _http._tcp.moon-svc.solar-system.svc.cluster.local

      Server:         10.100.0.10
      Address:        10.100.0.10#53

      Name:   _http._tcp.moon-svc.solar-system.svc.cluster.local
      Address: 10.100.195.82
      ```
      We have confirmed the following: 
      * The Service Discovery Address "` _http._tcp.moon-svc.solar-system.svc.cluster.local`" resolves to the
      `clusterIP` address of `10.100.195.82` as it is a "normal" service
      * Again, we see `kube-dns` is the internal kubernetes DNS and is available on `10.100.0.10:53`

### Replace with "Headless" Service

We will now change our "normal" service to a headless service so that Nova can
discover the endpoint ipaddress of all pods behind our **sun** and **moon**
services and load balance the pods directly.

1. Inspect the
  [manifest](../../deployments/simple-app/simple-app-headless-service.yaml) that
  **explicitly sets** `clusterIP: None` 
  
   ```bash
   # Inspect the Manifest file to change to headless service
   bat deployments/simple-app/simple-app-headless-service.yaml

   spec:
      clusterIP: None
      #... 
   spec:
      clusterIP: None
   ```
1. Delete the existing "normal" services, `moon-svc` and `sun-svc` then apply
   the alternative manifest, recreating the services as "headless"
  
   ```bash
   # Check services names
   kubectl get service -n solar-system
   NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
   moon-svc   ClusterIP   10.100.195.82    <none>        80/TCP    6h36m
   sun-svc    ClusterIP   10.100.130.214   <none>        80/TCP    6h36m
   ```
   ```bash
   # Delete existing "normal" services, `moon-svc` and `sun-svc` in the namespace solar-system
   kubectl delete service moon-svc -n solar-system
   kubectl delete service sun-svc -n solar-system
   
   service "moon-svc" deleted 
   service "sun-svc" deleted 
   ```
   ```bash
   # Check the "normal" Services are deleted
   kubectl get service -n solar-system
   
   No resources found in solar-system namespace.

   ```
   ```bash
   #  apply the alternative manifest to recreate the services as "headless"
   kubectl apply -f deployments/simple-app/simple-app-headless-service.yaml
   ``` 

### Run DNS checks on "Headless" Service

Now that the our services are "headless", you can use `kubectl exec` to do a
`nslookup` or `dig` and queryfor the **sun** and **moon** service and check
DNS is working correctly. 

First, lets scale both services to two pods each
so we know to expect exactly two SRV records, one for each pod in the service

1.  Scale out the sun and moon deployments to multiple pods, we can edit the
   manifest `yaml` file and reapply the config, or simply with a `kubectl scale` command: 

   ```bash
   kubectl scale deployments/moon --replicas=2 -n solar-system
   kubectl scale deployments/sun --replicas=2 -n solar-system

   deployment.apps/moon scaled
   deployment.apps/sun scaled
   ```

1.  Now that the our services are "headless" and scaled to two pods each, you
    can use `kubectl exec` to do a `nslookup` or `dig` and query  the **sun**
    service and check DNS is working correctly.

      ```bash
      # Find out Sun Application
      kubectl exec -i -t network-tools -- nslookup  _http._tcp.sun-svc.solar-system.svc.cluster.local

      Server:         10.100.0.10
      Address:        10.100.0.10#53
   
      Name:   _http._tcp.sun-svc.solar-system.svc.cluster.local
      Address: 192.168.72.194
      Name:   _http._tcp.sun-svc.solar-system.svc.cluster.local
      Address: 192.168.32.100
      ```
   
      We have confirmed the following: 
      * The Service Discovery Address
      "`_http._tcp.sun-svc.solar-system.svc.cluster.local`" resolves to two pods,
      with the address `192.168.72.194` and `192.168.32.100`, as it is a "headless"
      service
      * `kube-dns` is the internal kubernetes DNS and is available on
      `10.100.0.10:53`
  
1.  Run `kubectl exec` to do a `nslookup`once again for the **moon** service

      ```bash
      # Find out Moon Application
      kubectl exec -i -t network-tools -- nslookup  _http._tcp.moon-svc.solar-system.svc.cluster.local

      Server:         10.100.0.10
      Address:        10.100.0.10#53
   
      Name:   _http._tcp.moon-svc.solar-system.svc.cluster.local
      Address: 192.168.70.95
      Name:   _http._tcp.moon-svc.solar-system.svc.cluster.local
      Address: 192.168.26.52
      ```
      We have confirmed the following: 
         * The Service Discovery Address
         "`_http._tcp.moon-svc.solar-system.svc.cluster.local`" resolves to two pods,
         with the address `192.168.70.95` and `192.168.26.52`, as it is a "headless"
         service
         * Again, we see `kube-dns` is the internal kubernetes DNS and is available on `10.100.0.10:53`

### See load balancing via service in action

1. Make some `curl` request to ther service discovery address from the network
   utility container and witness request "load balance" between all pods *randomly*

      ```bash
      # Sun
      kubectl exec -i -t network-tools \
         -- /bin/bash -c "for i in {1..10}; \
            do curl -s http://_http._tcp.sun-svc.solar-system.svc.cluster.local:8080 | \
            grep 'Server address'; done"

      Server address: 192.168.72.194:8080
      Server address: 192.168.72.194:8080
      Server address: 192.168.72.194:8080
      Server address: 192.168.32.100:8080
      Server address: 192.168.32.100:8080
      Server address: 192.168.72.194:8080
      Server address: 192.168.32.100:8080
      Server address: 192.168.72.194:8080
      Server address: 192.168.72.194:8080
      Server address: 192.168.32.100:8080
      ```

      ```bash
      # Moon
      kubectl exec -i -t network-tools \
         -- /bin/bash -c "for i in {1..10}; \
         do curl -s http://_http._tcp.moon-svc.solar-system.svc.cluster.local:8080 | \
         grep 'Server address'; done"

      Server address: 192.168.70.95:8080
      Server address: 192.168.26.52:8080
      Server address: 192.168.26.52:8080
      Server address: 192.168.70.95:8080
      Server address: 192.168.70.95:8080
      Server address: 192.168.26.52:8080
      Server address: 192.168.70.95:8080
      Server address: 192.168.26.52:8080
      Server address: 192.168.26.52:8080
      Server address: 192.168.26.52:8080
      ```


### Optional: Use kubectl to find kube-dns address

Another way to identify the IP Address (`ClusterIP`) of our `kube-dns`' is to
simply use `kubectl`. 

Keep note of the `ClusterIP` found here, as we will need to input this in the
backend configuration's DNS Server to order for Nova to
queries to discover the IP and Ports of the applications in the pods or
services. Nova will keep track of the endpoint addresses in the backend groups,
and add and remove endpoints as services scale in the kubernetes cluster

1. Run the following command to find the `CLUSTER-IP` of the `kube-dns` service

   ```bash
   kubectl get service -o wide -n kube-system 

   NAME       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE    SELECTOR
   kube-dns   ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   7d6h   k8s-app=kube-dns
   ```

   For example, the `kube-dns` address is `10.100.0.10`. This is in fact the
   default address for AWS EKS. Again,  Keep a note of this, we will need it when
   setting up our backend groups using DNS service Discovery next.

Great, Now we have a better understanding of services and how that affects load
balancing in Nova. We are now ready to expose our application to the internet
with Nova. We will to that next.

Go back to [Table of Contents](../../README.md)