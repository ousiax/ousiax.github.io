---
layout: post
title: Access Kubernetes API with Client Certificates
date: 2019-02-01 15:05:40 +0800
categories: ['Kubernetes']
tags: ['Kubernetes']
---

- TOC
{:toc}

- - -

## Controlling Access to the Kubernetes API

Users [access the API](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/) using **kubectl**, client libraries, or by making REST requests. Both human users and [Kubernetes serevice accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) can be authorized for API access. When a request reaches the API, it goes through several stages, illustrated in the following diagram:

![Diagram of request handling steps for Kubernetes API request](https://d33wubrfki0l68.cloudfront.net/673dbafd771491a080c02c6de3fdd41b09623c90/50100/images/docs/admin/access-control-overview.svg)

For more information, see [Controlling Access to the Kubernetes API](https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/).

## Users in Kubernetes

All Kubernetes clusters have two categories of users: service accounts managed by Kubernetes, and normal users.

Normal users are assumed to be managed by an outside, independent service. An admin distributing private keys, a user store like Keystone or Google Accounts, even a file with a list of usernames and passwords. In this regard, *Kubernetes does not have objects which represent normal user accounts.* Normal users cannot be added to a cluster through an API call.

In contrast, service accounts are users managed by the Kubernetes API. They are bound to specific namespaces, and created automatically by the API server or mannually through API calls. Service accounts are tied to a set of credential stored as **Secret**, which are mounted into pods allowing in-cluster processed to talk to the Kubernetes API.

API requests are tied to either a normal user or a service account, or are treated as anonymous requests. This means every process inside or outside the cluster, from a human user typing **kubectl** on a workstation, to **kubelets** on nodes, to members of the control plane, must authenticate when making requests to the API server, or be treated as an anonymous user.

For more information, see [Authenticating in Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

### Authentication strategies

Kubernetes uses client certificates, bearer tokens, an authenticating proxy, or HTTP basic auth to authenticate API requests through authentication plugins. As HTTP request are made to the API server, plugins attempt to associate the following attributes with the request:

- Username: a string which identifies the end user. Common values might be **kube-admin** or **jane@example.com**.
- UID: a string which identifies the end user and attempts to be more consistent and unique than username.
- Groups: a set of strings which associate users with a set of commonly grouped users.
 - Extra fields: a map of strings to list of strings which holds additional information authorizers may find useful.

### X509 Client Certs

Client certificate authentication is enabled by passing the **--client-ca-file=SOMEFILE** option to API server. The referenced file must contain one or more certificates authorities to use to validate client certificates presented to the API server. If a client certificate is presented and verified, the common name of the subject is used as the user name for the request. As of Kubernetes 1.4, client certificates can also indicate a user’s group memberships using the certificate’s organization fields. To include multiple group memberships for a user, include multiple organization fields in the certificate.

For example, using the **openssl** command line tool to generate a certificate signing request:

```sh
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```

This would create a CSR for the username "jbeda", belonging to two groups, "app1" and "app2".

See [Managing Certificates](https://kubernetes.io/docs/concepts/cluster-administration/certificates/) for how to generate a client cert.

### Determine Whether a Request is Allowed or Denied

Kubernetes authorizes API requests using the API server. It evaluates all of the request attributes against all policies and allows or denies the request. All parts of an API request must be allowed by some policy in order to proceed. This means that permissions are denied by default.

For more information, see [Authorization Overview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)

### RBAC Authorization

#### Role and ClusterRole

In the RABC API, a role contains rules that represent a set of permissions. Perminssions are purely additive (there are no "deny" rules). A role can be defined within a namespace with a **Role**, or cluster-wide with a **ClusterRole**.

A **Role** can only be used to grant access to resources within a single namespace.

A **ClusterRole** can be used to grant the same permissions as a **Role**, but because they are cluster-scoped, they can also be used to grant access to:

- cluster-scoped resources (like nodes)
- no-resource endpoints (like "/healthz")
- namespaced resources (like pods) across all namespaces (need to **kubectl get pods --all-namespaces**, for example)

#### RoleBinding and ClusterRoleBinding

A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts), and a reference to the role being granted. Permissions can be granted within a namespace with a **RoleBinding**, or cluster-wide with a **ClusterRoleBinding**.

**roleRef** is how you will actually create the binding. The **kind** will be either **Role** or **ClusterRole**, and the **name** will reference the name of the specific **Role** or **ClusterRole** yo want.

A **RoleBinding** may reference a **Role** in the same namespace.

A **RoleBinding** may also reference a **ClusterRole** to grant the permissions to namespaced resources defined in the **ClusterRole** within the **RoleBinding**'s namespace. This allows administrators to define a set of common roles for the entire cluster, then reuse them with multiple namespaces.

Finally, a **ClusterRoleBinding** may be used to grant permissions at the cluster level and in all namespaces.

For more information, see [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).
## Configure Access to Kubernetes Cluster

#### 1. Create a Normal User with X.509 Client Certificate

```sh
# Generate a certificate signing request
openssl req -newkey rsa:2048 -nodes -keyout kube-ops.key -out kube-ops.csr -subj "/CN=kube-ops"
# Sign the certificate signing request kube-ops.csr with Kubernetes CA certificate.
sudo openssl x509 -req -in kube-ops.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out kube-ops.crt -days 1000
```

#### 2. Create a KUBECONFIG file. 

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <CA-DATA>
    server: https://<APISERVER-HOST>:<APISERVER-PORT>
  name: <CLUSTER-NAME>
contexts:
- context:
    cluster: <CLUSTER-NAME>
    user: <USER> # e.g. kube-ops
  name: <USER>@<CLUSTER-NAME>
kind: Config
users:
- name: <USER> # e.g. kube-ops
  user:
    client-certificate-data: <CLIENT-CRT-DATA>
    client-key-data: <CLIENT-KEY-DATA>
```

1. Update `<APISERVER-HOST>` and `<APISERVER-PORT>` with you Kubernetes API server (i.e. master) host and port.
1. Update `<CLUSTER-NAME>` with your Kubernetes cluster name.
1. Update `<USER>` with "kube-ops"
1. Update `<CA-DATA>` with the based64 encoded Kubernetes CA certificate.
1. Update `<CLIENT-CRT-DATA>` with the based64 encoded client certificate *kube-ops.crt*.
1. Update `<CLIENT-KEY-DATA>` with the based64 encoded cleint key *kube-ops.key*.

You can generate `<CA-DATA>`, `<CLIENT-CRT-DATA>` and `<CLIENT-KEY-DATA` with the following command:

```sh
# Generate the <CA-DATA>
sudo cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '\n'
# Generate the <CLIENT-CRT-DATA>
cat kube-ops.crt | base64 | tr -d '\n'
# Generate the <CLIENT-KEY-DATA>
cat kube-ops.key | base64 | tr -d '\n'
```

#### 3. Grant the `cluster-admin` `ClusterRole` to a user named "kube-ops"

```sh
# Gives the user *kube-ops* full control over every resource in the cluster and in all namespace with a **ClusterRoleBinding** with the default **ClusterRole** *cluster-admin*.
kubectl create clusterrolebinding kube-ops --clusterrole=cluster-admin --user=kube-ops
```

#### 4. Test the *config* and RBAC rule.

```sh
# Update <CLUSTER-NAME> with your Kubernetes cluster name.
kubectl --kubeconfig=./config --context=kube-ops@<CLUSTER-NAME> get clusterrolebindings kube-ops
```

## References

1. [https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/](https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/)
1. [https://kubernetes.io/docs/reference/access-authn-authz/authentication/](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)
1. [https://kubernetes.io/docs/reference/access-authn-authz/authorization/](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)
1. [https://kubernetes.io/docs/reference/access-authn-authz/rbac/](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
1. [https://kubernetes.io/docs/concepts/cluster-administration/certificates/](https://kubernetes.io/docs/concepts/cluster-administration/certificates/)
1. [https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/](
https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
1. [https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)
