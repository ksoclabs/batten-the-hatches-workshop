
Drops even the default capabilities:  
🌐 https://github.com/moby/moby/blob/v20.10.5/oci/caps/defaults.go
🔥 E.g. Mitigates `CapNetRaw` attack - DNS Spoofing on Kubernetes Clusters  
🌐 https://blog.aquasec.com/dns-spoofing-kubernetes-clusters

🚧 Drop Capabilities pitfalls

Some images require capabilities
Add necessary caps to kubernetes leveraging `securityContext`
Alternative: Find image with same app that does not require caps, e.g. `nginxinc/nginx-unprivileged`