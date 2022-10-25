The RBAC security section of this workshop can be ran by executing the following command:

```bash
./workshop/2-rbac/demo/interactive-demo.sh
```

This will start a demo that will walk you through the different concepts of RBAC security.

Commandss for `list` demo:

```bash
curl -k https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/sec-ctx/secrets/abc -H "Authorization: Bearer $(kubectl -n sec-ctx get secrets -ojson | jq '.items[]| select(.metadata.annotations."kubernetes.io/service-account.name"=="only-list-secrets-sa")| .data.token' | tr -d '"' | base64 -d)"
```

```bash
curl -k https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/sec-ctx/secrets?limit=500 -H "Authorization: Bearer $(kubectl -n sec-ctx get secrets -ojson | jq '.items[]| select(.metadata.annotations."kubernetes.io/service-account.name"=="only-list-secrets-sa")| .data.token' | tr -d '"' | base64 -d)"
```

Now we know what we should be looking for its time to perform an audit of your cluster.

## Audit

The audit section of this workshop can be ran by executing the following command:

```bash
./workshop/3-audit/demo/interactive-demo.sh
```

## Guardrails

Now that we have performed an audit of our cluster we can start to implement guardrails to prevent the issues we found from happening again.

For this section of the workshop click [here](4-guardrails.md).

