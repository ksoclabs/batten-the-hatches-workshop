Timeframe: 15 minutes

In this tutorial, you will learn how to audit the configuration of your cluster.

## CIS Kubernetes Benchmarks (for GKE)

The Center for Internet Security (CIS) releases benchmarks for best practice security recommendations. 
The CIS Kubernetes Benchmark is a set of recommendations for configuring Kubernetes to support a strong security posture. 
The Benchmark is tied to a specific Kubernetes release. 
The CIS Kubernetes Benchmark is written for the open source Kubernetes distribution and intended to be as universally applicable across distributions as possible.

As we are running this workshop on GKE we will use the [CIS Kubernetes Benchmark for GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/cis-benchmarks#accessing-gke-benchmark).

## Scored vs. Not Scored

The CIS Benchmark has two types of recommendations:

- Scored
- Not Scored

Scored recommendations are required to pass the benchmark.
Not scored recommendations are considered best practice and are recommended, but not required to pass the benchmark.

## Benchmarking our cluster

We will benchmark our cluster using the [kube-bench](https://github.com/aquasecurity/kube-bench) tool.
`kube-bench` is a Go application that checks whether Kubernetes is deployed according to the CIS Kubernetes Benchmark.
The tool can be run as a pod in the cluster, or as a standalone binary on a Linux node.

### Run kube-bench as a Pod

To run `kube-bench` as a Pod, run the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-gke.yaml
```

This will create a `kube-bench` job. You can view the job logs using the following command:

```bash
kubectl logs -f job/kube-bench
```

