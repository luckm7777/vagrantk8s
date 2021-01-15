# Prerequisites
- Vagrant
- kubectl
- Helm

# Steps
1. Run vagrant
vagrant up

2. Install local helm chart
helm install myrevproxy myrevproxy/ --values myrevproxy/values.yaml --kubeconfig shared/kubeconfig

3. curl local machine IP with its NodePort
curl 192.168.65.100:32222
curl 192.168.65.101:32222
curl 192.168.65.102:32222
