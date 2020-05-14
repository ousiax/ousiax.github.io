---
layout: post
title: 1 - Kubernetes Objects
date: 2019-02-22 17:55:05 +0800
categories: ['kubernetes']
tags: ['kubernetes']
---

- TOC
{:toc}

- - -

### YAML

- Learn YAML in Y minutes: https://learnxinyminutes.com/docs/yaml/
- YAML Multiline: https://yaml-multiline.info/
- Online YAML Validator: http://www.yamllint.com/
- YAML official website: https://yaml.org/
- `string`, `number`, `bool`, `null`
- `object`/`map`, `array`/`list`

#### YAML to JSON

```yaml
---
key: value
another_key: Another value goes here.
a_number_value: 100
boolean: true
null_value: null
literal_block: |
    This entire block of text will be the value of the 'literal_block' key,
    with line breaks being preserved.

    The literal continues until de-dented, and the leading indentation is
    stripped.

        Any lines that are 'more-indented' keep the rest of their indentation -
        these lines will be indented by 4 spaces.
folded_style: >
    This entire block of text will be the value of 'folded_style', but this
    time, all newlines will be replaced with a single space.

    Blank lines, like above, are converted to a newline character.

        'More-indented' lines keep their newlines, too -
        this text will appear over two lines.
   
   
...
```

```json
{
  "key": "value",
  "another_key": "Another value goes here.",
  "a_number_value": 100,
  "boolean": true,
  "null_value": null,
  "literal_block": "This entire block of text will be the value of the 'literal_block' key,\nwith line breaks being preserved.\n\nThe literal continues until de-dented, and the leading indentation is\nstripped.\n\n    Any lines that are 'more-indented' keep the rest of their indentation -\n    these lines will be indented by 4 spaces.\n",
  "folded_style": "This entire block of text will be the value of 'folded_style', but this time, all newlines will be replaced with a single space.\nBlank lines, like above, are converted to a newline character.\n    'More-indented' lines keep their newlines, too -\n    this text will appear over two lines.\n"
}
```

### Understanding Kubernetes Objects

- Kubernetes Objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster. Specifically, they can describe:
    - What containerized applications are running (and on which nodes)
    - The resources available to those applications
    - The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance
- A Kubernetes object is a “record of intent”–once you create the object, the Kubernetes system will constantly work to ensure that object exists. By creating an object, you’re effectively telling the Kubernetes system what you want your cluster’s workload to look like; this is your cluster’s desired state.

#### Object Spec and Status

- Every Kubernetes object includes two nested object fields that govern the object’s configuration: the object **spec** and the object **status**.
- The **spec**, which you must provide, describes your **desired state** for the object–the characteristics that you want the object to have.
- The **status** describes the **actual state** of the object, and is supplied and updated by the Kubernetes system.
- At any given time, the Kubernetes Control Plane actively manages an object’s actual state to match the desired state you supplied.

#### Describing a Kubernetes Object

- When you create an object in Kubernetes, you must provide the object spec that describes its desired state, as well as some basic information about the object (such as a name).
- When you use the Kubernetes API to create the object (either directly or via `kubectl`), that API request must include that information as JSON in the request body.
- Most often, you provide the information to `kubectl` in a `.yaml` file. `kubectl` converts the information to JSON when making the API request.

#### Deployment Object

```yaml
# kubectl create deployment nginx --image=nginx:1.15.8 --dry-run -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
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
      - image: nginx:1.15.8
        name: nginx
status: {}
```

#### kubectl explain

```sh
$ kubectl explain --help
$ kubectl api-resources
$ kubectl api-resources --namespaced --api-group=apps
$ kubectl explain deploy
$ kubectl explain deploy.metadata
$ kubectl explain deploy.metadata.name
$ kubectl explain deploy.spec.
$ kubectl explain deploy.spec.replicas
$ kubectl explain deploy.spec.template
$ kubectl explain pod.spec
$ kubectl explain pod.spec.containers
```

### Names and UIDs

- Names are a client-provided string that refers to an object in a resource URL, such as /api/v1/pods/some-name.
- **Only one object of a given kind can have a given name within a namespace at a time.**
- UIDs are Kubernetes systems-generated string to uniquely identify objects.
- Every object created over the whole lifetime of a Kubernetes cluster has a distinct UID. It is intended to distinguish between historical occurrences of similar entities.
 
#### kubectl get deployment -o yaml

```yaml
$ kubectl create deployment nginx --image=nginx:1.15.8
deployment.apps/nginx created
$ kubectl get deployment nginx -oyaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2019-02-25T05:58:42Z"
  generation: 1
  labels:
    app: nginx
  name: nginx
  namespace: default
  resourceVersion: "890280"
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/nginx
  uid: 6793a7f2-38c2-11e9-b3e0-000c290f1152
spec:
status:
```

### Namespaces

- Kubernetes supports multiple **virtual clusters** with namespaces backed by the same physical cluster.
- Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces.
- Kubernetes starts with three initial namespaces:
    - **default** The default namespace for objects with no other namespace
    - **kube-system** The namespace for objects created by the Kubernetes system
    - **kube-public** This namespace is created automatically and is readable by all users (including those not authenticated).
- To see which Kubernetes resources are and aren’t in a namespace:

    ```sh
    # In a namespace
    $ kubectl api-resources --namespaced=true
    # Not in a namespace
    $ kubectl api-resources --namespaced=false
    ```
#### kubectl config <small>& context</small>

```sh
# Show the configuration information associated with the current context
$ kubectl config view --minify
# Show the namespace of the current context
$ kubectl config view --minify -o=jsonpath='{.contexts[0].context.namespace}'
$ kubectl get ns
NAME          STATUS   AGE
default       Active   25d
kube-public   Active   25d
kube-system   Active   25d
$ kubectl create ns foobar
namespace/foobar created
$ kubectl get ns
NAME          STATUS   AGE
default       Active   25d
foobar        Active   3s
kube-public   Active   25d
kube-system   Active   25d
```

```sh
$ kubectl create deployment nginx --image=nginx:1.15
deployment.apps/nginx created
$ kubectl get deployment
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           5s
$ kubectl create deployment nginx --image=nginx:1.15 -n foobar
deployment.apps/nginx created
$ kubectl get deployment -n foobar
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           19s
$ kubectl get deployment -l app=nginx --all-namespaces 
NAMESPACE   NAME    READY   UP-TO-DATE   AVAILABLE   AGE
default     nginx   1/1     1            1           97s
foobar      nginx   1/1     1            1           55s
$ kubectl delete ns foobar 
namespace "foobar" deleted
```

### Labels and Selectors

- **Labels** are key/value pairs that are attached to objects, such as pods.
- Labels are intended to be used to specify **identifying attributes of objects** that are meaningful and relevant to users, but do not directly imply semantics to the core system.
- Labels can be used to **organize and to select subsets of objects**.
- Labels can be attached to objects at creation time and subsequently added and modified at any time.
- Each object can have a set of key/value labels defined.
- Each Key must be unique for a given object.

#### Labels Syntax and Character Set

- Valid label keys have two segments: an optional prefix and name, separated by a slash (/).
    - The name segment is required and must be 63 characters or less, beginning and ending with an alphanumeric character ([a-z0-9A-Z]) with dashes (-), underscores (\_), dots (.), and alphanumerics between.
    - The prefix is optional. If specified, the prefix must be a DNS subdomain: a series of DNS labels separated by dots (.), not longer than 253 characters in total, followed by a slash (/).
    - If the prefix is omitted, the label Key is presumed to be private to the user. Automated system components (e.g. kube-scheduler, kube-controller-manager, kube-apiserver, kubectl, or other third-party automation) which add labels to end-user objects must specify a prefix.
    - The kubernetes.io/ and k8s.io/ prefixes are reserved for Kubernetes core components.
- Valid label values must be 63 characters or less and must be empty or begin and end with an alphanumeric character ([a-z0-9A-Z]) with dashes (-), underscores (\_), dots (.), and alphanumerics between.

#### kubectl label

```sh
$ kubectl create deployment nginx --image=nginx:1.15
deployment.apps/nginx created
$ kubectl get deployment --show-labels 
NAME    READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
nginx   1/1     1            1           8s    app=nginx
$ kubectl label deployment nginx environment=development
deployment.extensions/nginx labeled
$ kubectl get deployment --show-labels 
NAME    READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
nginx   1/1     1            1           38s   app=nginx,environment=development
$ kubectl create deployment nginx-qa --image=nginx:1.15
deployment.apps/nginx-qa created
$ kubectl get deployment --show-labels 
NAME       READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
nginx      1/1     1            1           68s   app=nginx,environment=development
nginx-qa   1/1     1            1           7s    app=nginx-qa
$ kubectl label deployment nginx-qa environment=qa
deployment.extensions/nginx-qa labeled
```

```sh
$ kubectl get deployment -l environment=development
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           116s
$ kubectl get deployment -l 'environment in (development, qa)'
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
nginx      1/1     1            1           2m16s
nginx-qa   1/1     1            1           75s
$ kubectl label deployment nginx-qa environment-
deployment.extensions/nginx-qa labeled
$ kubectl get deployment nginx-qa --show-labels 
NAME       READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
nginx-qa   1/1     1            1           116s   app=nginx-qa
$ kubectl get deployment -l 'environment'
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           9m43s
$ kubectl get deployment -l '!environment'
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
nginx-qa   1/1     1            1           8m46s
```

#### Label Selectors

- Unlike names and UIDs, labels do not provide uniqueness. In general, we expect many objects to carry the same label(s).
- Via a label selector, the client/user can **identify a set of objects**.
- The label selector is the core grouping primitive in Kubernetes.
- The API currently supports two types of selectors: **equality-based** and **set-based**.
- A label selector can be made of multiple requirements which are comma-separated, and the comma separator acts as a logical **AND (&&)** operator.

##### Equality-based Requirement

- Equality- or inequality-based requirements allow filtering by label keys and values.
- Matching objects must satisfy all of the specified label constraints, though they may have additional labels as well.
- Three kinds of operators are admitted `=`, `==`, `!=`. The first two represent equality (and are simply synonyms), while the latter represents inequality.

```sh
# selects all resources with key equal to environment and value equal to production
environment = production
# selects all resources with key equal to tier and value distinct from frontend,
# and all resources with no labels with the tier key
tier != frontend
```

##### Set-based Requirement

- Set-based label requirements allow filtering keys according to a set of values.
- Three kinds of operators are supported: `in`, `notin` and `exists` (only the key identifier).

```sh
# selects all resources with key equal to environment and value equal to production or qa
environment in (production, qa)
# selects all resources with key equal to tier and values other than frontend and backend,
# and all resources with no labels with the tier key
tier notin (frontend, backend)
# selects all resources including a label with key partition; no values are checked
partition
# selects all resources without a label with key partition; no values are checked
!partition
```

#### matchLabels / matchExpressions

- **matchLabels** is a map of **{key,value}** pairs.
    - A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "**key**", the operator is "**In**", and the values array contains only "value".
- **matchExpressions** is a list of pod selector requirements.
    - Valid operators include `In`, `NotIn`, `Exists`, and `DoesNotExist`.
    - The values set must be non-empty in the case of In and NotIn.
- All of the requirements, from both matchLabels and matchExpressions are **AND**ed together – they must all be satisfied in order to match.

```sh
# kubectl explain deployment.spec.selector.
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```

#### NodeSelector

```yaml
# kubectl explain pod.spec.nodeSelector
# kubectl get po elasticsearch-logging-0 -o yaml
apiVersion: v1
kind: Pod
metadata:
spec:
  containers:
  nodeSelector:
    node.kubernetes.io/elasticsearch-logging-storage-ready: "true"
status:
```

### Annotations

- You can use either labels or annotations to attach **metadata** to Kubernetes objects.
- Labels can be used to select objects and to find collections of objects that satisfy certain conditions.
- In contrast, annotations are not used to identify and select objects.
- The metadata in an annotation can be small or large, structured or unstructured, and can include characters not permitted by labels.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},"spec":{"selector":{"matchExpressions":[{"key":"environment","operator":"In","values":["qa"]}],"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx","environment":"qa"}},"spec":{"containers":[{"image":"nginx:1.15.8","name":"nginx","ports":[{"containerPort":80}]}]}}}}
spec:
status:
```

#### Annotations Syntax and Character Set

- Annotations are key/value pairs.
- Valid annotation keys have two segments: an optional prefix and name, separated by a slash (/).
- The name segment is required and must be 63 characters or less, beginning and ending with an alphanumeric character ([a-z0-9A-Z]) with dashes (-), underscores (\_), dots (.), and alphanumerics between.
- The prefix is optional. If specified, the prefix must be a DNS subdomain: a series of DNS labels separated by dots (.), not longer than 253 characters in total, followed by a slash (/).
- If the prefix is omitted, the annotation Key is presumed to be private to the user. Automated system components (e.g. kube-scheduler, kube-controller-manager, kube-apiserver, kubectl, or other third-party automation) which add annotations to end-user objects must specify a prefix.
- The **kubernetes.io/** and **k8s.io/** prefixes are reserved for Kubernetes core components.

### Object Management Using Kubectl

- [https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-command/](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-command/)
- [https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/)
- [https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/)

### References

- https://learnxinyminutes.com/docs/yaml/
- https://yaml-multiline.info/
- http://www.yamllint.com/
- https://yaml.org/
- https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/
- https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/
- https://github.com/ahmetb/kubectx
- https://github.com/kubernetes-sigs/kustomize/blob/master/docs/kustomization.yaml

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
