Firstly, we need to understand what assets we are going to auditing.

The following are useful assets to audit:

1. Kubernetes Version
2. Cloud Provider (AWS, GCP, Azure, etc.)
3. Kubernetes Networking Metadata

## Kubernetes Version

The version of Kubernetes is an important aspect of your audit. 
You should be aware of the version of Kubernetes you are running and how it is supported. 
You should have a clear understanding of the Kubernetes version lifecycle and the support policy of your Kubernetes distribution.

The Kubernetes project maintains a [version skew policy](https://kubernetes.io/releases/version-skew-policy/) that defines the relationship between the Kubernetes control plane and the Kubernetes nodes. 
This policy defines the supported versions of Kubernetes and the minimum version of the control plane for each Kubernetes version. 
This policy also defines the maximum version skew between the control plane and the node components.

You can find the supported versions of Kubernetes in the release notes for each release. 
For example, the Kubernetes release notes for version 1.25.0 can be found [here](https://kubernetes.io/releases/#release-v1-25).

The version of Kubernetes you are running can be found by running the following command:

```bash
$ kubectl version
```

The output of the command should be similar to the following:

```bash
Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"2d3c76f9091b6bec110a5e63777c332469e0cba2", GitTreeState:"clean", BuildDate:"2021-09-28T14:51:23Z", GoVersion:"go1.16.7", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"2d3c76f9091b6bec110a5e63777c332469e0cba2", GitTreeState:"clean", BuildDate:"2021-09-28T14:51:23Z", GoVersion:"go1.16.7", Compiler:"gc", Platform:"linux/amd64"}
```

The output above shows that the client version is 1.25.0 and the server version is 1.25.0. 
The client version is the version of the `kubectl` binary you are running. 
The server version is the version of the Kubernetes control plane you are connected to.

If you are running a managed Kubernetes service, you should check the version of Kubernetes that is supported by the service. 

- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [Google GKE](https://cloud.google.com/kubernetes-engine/docs/release-notes)
- [Azure AKS](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)

## Official Kubernetes CVE Feed
Kubernetes provides an [official CVE](https://kubernetes.io/docs/reference/issues-security/official-cve-feed/) feed that you should subscribe to in order to ensure that your cluster versions are always up-to-date. 

## Cloud Provider

If you are running Kubernetes on a cloud provider, you should be aware of the cloud provider you are using. 
You should also be aware of the capabilities of the cloud provider and how it impacts your Kubernetes cluster.

If you are running Kubernetes on AWS, you should be aware of the capabilities of EKS. 
You should also be aware of the limitations of EKS and how it impacts your Kubernetes cluster.

For example, if you are running Kubernetes on AWS, you should be aware of the following:

- [EKS Service Limits](https://docs.aws.amazon.com/eks/latest/userguide/service_limits.html)
- [EKS Security Groups](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html)

If you are running Kubernetes on GCP, you should be aware of the capabilities of GKE.

- [GKE Service Limits](https://cloud.google.com/kubernetes-engine/quotas)

If you are running Kubernetes on Azure, you should be aware of the capabilities of AKS.

- [AKS Service Limits](https://docs.microsoft.com/en-us/azure/aks/quotas-skus-regions)
- [AKS Security Groups](https://docs.microsoft.com/en-us/azure/aks/concepts-network#security-groups)

## Kubernetes Networking Metadata

You should be aware of the networking metadata of the cloud provider and how it impacts your Kubernetes cluster.

If you are running Kubernetes on AWS, you should be aware of the following:

- [EKS Networking](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
- [EKS VPC CNI Plugin](https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html)

If you are running Kubernetes on GCP, you should be aware of the following:

- [GKE Networking](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview)

If you are running Kubernetes on Azure, you should be aware of the following:

- [AKS Networking](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [AKS Subnet](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#subnet)

## Kubernetes API Resources

The Kubernetes API 
Using `kubectl api-resources -o wide` shows all the resources, verbs and associated API-group:

```bash
kubectl api-resources -o wide
```
We get name, namespaced, kind, shortnames, and apiversion of the resources by executing the command as mentioned above.

*NAME* – Shows the source to which the permissions are related

*KIND* – Shows the title of the resource

*SHORTNAMES* - A very useful code-named when interrelating with kubectl resources

*APIVERSION* – Resembles the role required of the API groups

*VERBS* – Displays the existing available verbs, and it is helpful when describing RBAC rules.

## List all Container Images 

As you audit a Kubernetes cluster, it is important to understand exactly which container images are running inside of the environment. The following command will extract the images in your cluster for all namespaces:

```bash
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```

## List all Kubernetes Objects

To understand our attack surface and scope for the audit we need to ensure that a complete list of all running objects is obtained. The following command can quickly enumerate `pods`, `deployments`, `services`, and more:

```bash
kubectl get all --all-namespaces
```

You will notice that the output of `kubectl get all` is not comprehensive. An open-source project called [ketall](https://github.com/corneliusweig/ketall) is installed in your shell. This will print out a much more comprehensive inventory to the screen. 

```bash
ketall
```

## Next Steps

Now lets begin our audit in-depth by looking at the configuration of our Kubernetes workloads [here](2-workload-security.md).
