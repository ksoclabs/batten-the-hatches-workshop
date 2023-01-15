# Getting Started

These instructions will set up your workshop environment. 

*PLEASE USE AN INCOGNITO BROWSER SESSION*

1. Login to [https://console.cloud.google.com](https://console.cloud.google.com)
2. Select your project from the top left dropdown
3. Click on the "Hamburger" menu in the top left and select "Kubernetes Engine" from the menu that appears
4. Click on your cluster name
5. Click on the "Connect" button
6. Click on the "Run in Cloud Shell" button
7. Copy the command that appears and paste it into the Cloud Shell and press enter
8. Then run `git clone https://github.com/ksoclabs/batten-the-hatches-workshop.git`
9. Then run `cd batten-the-hatches-workshop`
10. Then run `cd workshop && make init`

## Validation

When the script is finished, verify it worked correctly.

    ```console
    kubectl get pods -n sec-ctx
    ```

The output should look similar to this (some workloads are crashing which is expected at this point):

```
NAME                                             READY   STATUS                       RESTARTS   AGE
all-at-once-6df575c7f4-zgfkz                     1/1     Running                      0          2m40s
allow-no-privilege-escalation-749bc6b98c-swv9j   1/1     Running                      0          2m43s
empty-dirs-nginx-read-only-fs-98444b967-64cww    1/1     Running                      0          73s
failing-nginx-read-only-fs-545cfcb4c7-f85vw      0/1     CrashLoopBackOff             3          73s
read-only-fs-5f585bd48b-jwn9z                    1/1     Running                      0          74s
run-as-non-root-69dd94dd89-9vnjs                 0/1     CreateContainerConfigError   0          79s
run-as-non-root-unprivileged-755d88d78c-dj7hf    1/1     Running                      0          79s
run-as-user-976bb47fd-9xw5c                      0/1     CrashLoopBackOff             3          77s
run-as-user-unprivileged-6b755d5ccd-7blx8        1/1     Running                      0          77s
run-with-certain-caps-6d8fdf5c96-7nfkr           1/1     Running                      0          75s
run-with-seccomp-5b9fdfff4f-n5htr                1/1     Running                      0          76s
run-without-caps-f545b8cb9-m2fr5                 0/1     CrashLoopBackOff             3          75s
run-without-caps-unprivileged-6854865667-w5lwf   1/1     Running                      0          74s
```

If the output looks similar to the above, you are ready to move on to the [next section](1-inventory.md).