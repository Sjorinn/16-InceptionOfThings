echo "->Installing Helm and k3d:"
if [ -f /etc/alpine-release ]; then
	cd /sync
	apk add helm docker openrc
	service docker start
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	curl -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubectl > /tmp/kubectl
	install /tmp/kubectl /usr/local/bin/kubectl
fi

echo "->creating k3d cluster:"
k3d cluster create bonus \
	--port 2222:22@loadbalancer \
	--port 8080:80@loadbalancer \
	--port 8443:443@loadbalancer \
	--port 8081:8080@loadbalancer \
	--port 8888:8888@loadbalancer

if [ -f /etc/alpine-release ]; then
	VAGRANT_USER=vagrant
	echo "->Copying k3d credentials to vagrant user"
	mkdir -p /home/$VAGRANT_USER/.kube && cp /root/.kube/config /home/$VAGRANT_USER/.kube/config && chown $VAGRANT_USER /home/$VAGRANT_USER/.kube/config
fi

echo "->Installing gitlab:"
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm install -n gitlab gitlab gitlab/gitlab \
	-f ./confs/gitlab-minimum.yaml

echo "->Installing AgoCD"
kubectl create namespace argocd
kubectl create namespace dev
curl https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml | kubectl apply -n argocd -f -
kubectl -n argocd set env deployment/argocd-server ARGOCD_SERVER_INSECURE=true

echo "->Setup ingress"
kubectl apply -n argocd -f ./confs/ingress-argocd.yaml

echo "->Wait for gitlab to be ready"
sudo kubectl wait --for=condition=available deployments --all -n gitlab
sleep 30
sudo kubectl port-forward svc/gitlab-webservice-default --address 192.168.56.110 -n gitlab 8082:8080 2>&1 >/dev/null &
echo "Argocd password: " $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
