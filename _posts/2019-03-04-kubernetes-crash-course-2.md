---
layout: post
title: 2 - Kubernetes Pods
date: 2019-03-04 17:55:05 +0800
categories: ['Kubernetes']
tags: ['Kubernetes']
---

- TOC
{:toc}

<style>
img {
 max-width: 55%;
}
</style>

- - -

![Pods](/assets/kubernetes/pods.jpg)
![Mendel Seven Characters](https://upload.wikimedia.org/wikipedia/commons/e/ea/Mendel_seven_characters.svg)

### What is a Pod?

- Pods are the **smallest deployable units** of computing that can be created and managed in Kubernetes.
- A pod (as in a pod of whales or pea pod) is a group of **one or more containers** (such as Docker containers), with **shared storage/network**, and a **specification** for how to run the containers.
- A pod’s contents are always co-located and co-scheduled, and run in a shared context (a set of Linux **namespaces**, **cgroups**).
- A pod models an application-specific "**logical host**" - it contains one or more application containers which are relatively tightly coupled — in a pre-container world, being executed on the same physical or virtual machine would mean being executed on the same logical host.

### Pods and Containers

- Pods in a Kubernetes cluster can be used in two main ways:
- **Pods that run a single container.**
    - The “one-container-per-Pod” model is the most common Kubernetes use case; in this case, you can think of a Pod as a wrapper around a single container, and Kubernetes manages the Pods rather than the containers directly.
- **Pods that run multiple containers that need to work together.**
    - A Pod might encapsulate an application composed of multiple co-located containers that are tightly coupled and need to share resources.
    - These co-located containers might form a single cohesive unit of service–one container serving files from a shared volume to the public, while a separate "**sidecar**" container refreshes or updates those files.
    - The Pod wraps these containers and storage resources together as a single manageable entity.

### Pods and Multiple Containers

- Pods are designed to support multiple cooperating processes (as containers) that form a cohesive unit of service.
- The containers in a Pod are automatically **co-located** and **co-scheduled** on the same physical or virtual machine in the cluster.
- The containers can share resources and dependencies, communicate with one another, and coordinate when and how they are terminated.
- Note that grouping multiple co-located and co-managed containers in a single Pod is **a relatively advanced use case**. You should use this pattern only in specific instances in which your containers are tightly coupled. 

### Pods and Multiple Containers

- A multi-container pod that contains a file puller and a web server that uses a persistent volume for shared storage between the containers.

![Pods provide two kinds of shared resources for their constituent containers: networking and storage.](https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg)

### Pods Networking

- Each Pod is assigned **a unique IP address.**
- Every container in a Pod **shares the network namespace**, including the IP address and network ports.
- The hostname is set to the pod’s Name for the application containers within the pod.
- Containers inside a Pod can communicate with one another using **localhost**.
- When containers in a Pod communicate with entities outside the Pod, they must coordinate how they use the shared network resources (such as ports).

### Pods Storage

- A Pod can specify a set of shared storage **volumes**.
- All containers in the Pod can access the **shared volumes**, allowing those containers to **share data**.
- Volumes enable data to survive container restarts and to be shared among the applications within the pod.
- Volumes also allow **persistent data** (persistent volumes) in a Pod to survive in case one of the containers within needs to be restarted.

### Pods and Controllers

- Pods aren't intended to be treated as durable entities. **Like individual application containers, pods are considered to be relatively ephemeral (rather than durable) entities**.
- They won't survive scheduling failures, node failures, or other evictions, such as due to lack of resources, or in the case of node maintenance.
- Pods are created, assigned a unique ID (**UID**), and scheduled to nodes where they remain until termination (according to **restart policy**) or deletion.
- If a node dies, the pods scheduled to that node are scheduled for deletion, after a timeout period.
- A given pod (as defined by a UID) is not “rescheduled” to a new node; instead, it can be replaced by an identical pod, with even the same name if desired, but with a new UID
- In general, users shouldn’t need to create pods directly. They should almost always use **controllers** even for singletons, for example, **Deployments**.
- Controllers provide **self-healing** with a cluster scope, as well as **replication** and **rollout** management. 

#### Pod Templates

- Pod templates are pod specifications which are included in other controller objects with the field `.spec.template`, such as Deployments.
- The `.spec.template` has exactly the same schema as a pod, except it is nested and does not have an `apiVersion` or `kind`.
- Controllers use Pod Templates to make actual pods.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: nginx
spec:
  containers:
  - image: nginx:1.15
    name: nginx
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.15
        name: nginx
```

### Pod Lifecycle

![Pod Lifecycle](https://i0.wp.com/blog.openshift.com/wp-content/uploads/loap.png)

1. Not shown in the diagram, before anything else, the infra container is launched establishing namespaces the other containers join.
1. The first user-defined container launching is the **init container** which you can use for pod-wide initialization.
1. Next, the main container and the **post-start** hook launch at the same time, in our case after 4 seconds. You define hooks on a per-container basis. 
1. Then, at second 7, the **liveness** and **readiness** probes kick in, again on a per-container basis. 
1. At second 11, when the pod is killed, the **pre-stop** hook is executed and finally, the main container is killed, after a grace period. Note that the actual pod termination is a bit more complicated.

#### Container Lifecycle Hooks

There are two hooks that are exposed to Containers:

**PostStart**

This hook executes immediately after a container is created. However, there is no guarantee that the hook will execute before the container **ENTRYPOINT**. No parameters are passed to the handler.

**PreStop**

This hook is called immediately before a container is terminated due to an API request or management event such as liveness probe failure, preemption, resource contention and others. A call to the preStop hook fails if the container is already in terminated or completed state. It is blocking, meaning it is **synchronous**, so it must complete before the call to delete the container can be sent. No parameters are passed to the handler.

### Pod Status

- A Pod's **status** field is a **PodStatus** object, which has a **phase** field that is a simple, high-level summary of where the Pod is in its lifecycle.
- Here are the possible values for phase:
    `Pending, Running, Succeeded, Failed, Unknown, Completed, CrashLoopBackOff`
- A Pod has a PodStatus, which has an array of **PodConditions** through which the Pod has or has not passed.
- Each element of the PodCondition array has six possible fields:
    `lastProbeTime, lastTransitionTime, message, reason, status, type`

### Pod Phase

**Pending**

The Pod has been accepted by the Kubernetes system, but one or more of the Container images has not been created. This includes time before being scheduled as well as time spent downloading images over the network, which could take a while.

**Running**

The Pod has been bound to a node, and all of the Containers have been created. At least one Container is still running, or is in the process of starting or restarting.

**Succeeded**

All Containers in the Pod have terminated in success, and will not be restarted.

**Failed**

All Containers in the Pod have terminated, and at least one Container has terminated in failure. That is, the Container either exited with non-zero 
status or was terminated by the system.

**Unknown**

For some reason the state of the Pod could not be obtained, typically due to an error in communicating with the host of the Pod.

**Completed**

The pod has run to completion as there’s nothing to keep it running eg. Completed Jobs.

**CrashLoopBackOff**

This means that one of the containers in the pod has exited unexpectedly, and perhaps with a non-zero error code even after restarting due to restart policy.

### Pod Conditions

- The **lastProbeTime** field provides a timestamp for when the Pod condition was last probed.
- The **lastTransitionTime** field provides a timestamp for when the Pod last transitioned from one status to another.
- The **message** field is a human-readable message indicating details about the transition.
- The **reason** field is a unique, one-word, CamelCase reason for the condition’s last transition.
- The **status** field is a string, with possible values “True”, “False”, and “Unknown”.
- The **type** field is a string with the following possible values:
    - **PodScheduled**: the Pod has been scheduled to a node;
    - **Ready**: the Pod is able to serve requests and should be added to the load balancing pools of all matching Services;
    - **Initialized**: all init containers have started successfully;
    - **Unschedulable**: the scheduler cannot schedule the Pod right now, for example due to lacking of resources or other constraints;
    - **ContainersReady**: all containers in the Pod are ready.

### Restart Policy

- A PodSpec has a **restartPolicy** field with possible values **Always**, **OnFailure**, and **Never**.
- The default value is Always.
- **restartPolicy** applies to all Containers in the Pod.
- **restartPolicy** only refers to restarts of the Containers by the kubelet on the same node.
- Exited Containers that are restarted by the kubelet are restarted with an **exponential back-off** delay (10s, 20s, 40s …) capped at five minutes, and is reset after ten minutes of successful execution.

### Pod and Container Status

Once Pod is assigned to a node by scheduler, kubelet starts creating containers using container runtime.

There are three possible states of containers: **Waiting**, **Running** and **Terminated**.

```yaml
...
  State:          Waiting
   Reason:       ErrImagePull
...
```

```yaml
...
   State:          Running
    Started:      Wed, 30 Jan 2019 16:46:38 +0530
...
```

```yaml
...
  State:          Terminated
    Reason:       Completed
    Exit Code:    0
    Started:      Wed, 30 Jan 2019 11:45:26 +0530
    Finished:     Wed, 30 Jan 2019 11:45:26 +0530
...
```

### Container Probes

- A **Probe** is a diagnostic performed periodically by the kubelet to call a **Handler** on a Container.
- There are three types of handlers:

    **ExecAction**:

    - Executes a specified command inside the Container.

    - The diagnostic is considered successful if the command exits with a status code of 0.

    **TCPSocketAction**:

    - Performs a TCP check against the Container’s IP address on a specified port.
    - The diagnostic is considered successful if the port is open.

    **HTTPGetAction**:

    - Performs an HTTP Get request against the Container’s IP address on a specified port and path.
    - The diagnostic is considered successful if the response has a status code greater than or equal to 200 and less than 400.
- Each probe has one of three results:

    **Success**:

    - The Container passed the diagnostic.

    **Failure**:

    - The Container failed the diagnostic.

    **Unknown**:

    - The diagnostic failed, so no action should be taken.

#### livenessProbe / readinessProbe

- The kubelet can optionally perform and react to two kinds of probes on running Containers:
    - **livenessProbe**: Indicates whether the Container is running. If the liveness probe fails, the kubelet kills the Container, and the Container is subjected to its restart policy. If a Container does not provide a liveness probe, the default state is Success.
    - **readinessProbe**: Indicates whether the Container is ready to service requests. If the readiness probe fails, the endpoints controller removes the Pod’s IP address from the endpoints of all Services that match the Pod. The default state of readiness before the initial delay is Failure. If a Container does not provide a readiness probe, the default state is Success.

### ReplicaSet/Deployment

```sh
kubectl explain --api-version=apps/v1 ReplicaSet

kubectl explain --api-version=apps/v1 Deployment

kubectl explain --api-version=apps/v1 StatefulSet
```

### References

https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/
https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pod-templates
https://kubernetes.io/docs/concepts/workloads/pods/pod/
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#when-should-you-use-liveness-or-readiness-probes
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#example-states
https://blog.openshift.com/kubernetes-pods-life/
https://www.ianlewis.org/en/what-are-kubernetes-pods-anyway
https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
https://kubernetes.io/docs/concepts/storage/volumes/
https://kubernetes.io/docs/concepts/configuration/secret/
https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
https://kubernetes.io/docs/concepts/configuration/overview/#general-configuration-tips
https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
