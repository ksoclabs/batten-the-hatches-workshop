
Notes:

Why `runAsUser` and `runAsGroup` > 10000? 
🔥 Reduces risk to run as user existing on host
🔥 In case of container escape UID/GID does not have privileges on host
🔥 E.g. mitigates vuln in `runc` (used by Docker among others)  

🚧️ Running as unprivileged user pitfalls

Some official images run as root by default. Find a "trusted" image that does not run as root

UID 100000 lacks file permissions. Solutions:
 - Init Container sets permissions for volume
 - Permissions in image ➡️ `chmod`/`chown` in `Dockerfile`
 - Run in root Group - `GID 0`  
 
Useful Links
 - 🌐 https://docs.openshift.com/container-platform/4.3/openshift_images/create-images.html#images-create-guide-openshift_create-images
 - 🌐 https://kubernetes.io/blog/2019/02/11/runc-and-cve-2019-5736
