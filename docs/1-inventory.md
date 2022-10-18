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

## Next Steps

Now lets begin our audit in-depth by looking at the configuration of our Kubernetes cluster [here](2-cluster-configs.md).
