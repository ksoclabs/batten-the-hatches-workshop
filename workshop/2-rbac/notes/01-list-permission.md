
The list response contains all items in full, not just their name. 

Workloads with `LIST` permission cannot get a specific item from the API, but will get all of them in full when they list.

🔥`kubectl` hides this by default by choosing to only show you the object names, but it has all attributes of those objects.

🚧 How to Prevent

Only grant `LIST` permissions if you are also allowing that workload to `GET` all of that resource.

🌐 Useful Links

https://tales.fromprod.com/2022/202/Why-Listing-Is-Scary_On-K8s.html
https://kubernetes.io/docs/concepts/configuration/secret/#security-recommendations-for-developers