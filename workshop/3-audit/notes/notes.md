
Now we know what we are looking for its time to run a cluster audit.

We will leverage https://github.com/Shopify/kubeaudit to simplify the process.

We are going to look for the following:

- containers running as privileged.
- containers that allow privilege escalation.
- containers running as root.
- containers which do not have a read-only filesystem.
