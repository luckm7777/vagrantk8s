# 1. Intro

Code in this repository will:
- start three VMs using Vagrant
- install muti-node Kubernetes cluster on these VMs
- allow to install local Helm chart with sample reverse proxy handling requests to origin http://ifconfig.me and replying with requestor's IP address

Note: initially I planned to use http://ifconfig.co service, but it seems they have added CAPTCHA protection and request return full HTML documents. So I changed to equivalent service withm .me extension

# 2. Prerequisites
You should run this code on a decent machine with at least 16 GB of RAM (8 GB might suffice but 4 GB is definitely not enough). Modern CPU is also helpful here :)

You should have installed locally recent versions (as per January 2021) of:
- Virtualbox (as a Vagrant provider)
- Vagrant
- kubectl
- Helm
- curl

# 3. Execution steps
1. cd to the cloned repository directory
2. run vagrant `vagrant up`
3. install local helm chart `helm install myrevproxy myrevproxy/ --values myrevproxy/values.yaml --kubeconfig shared/kubeconfig`
4. You can observe pods creation using command `kubectl get pods --kubeconfig shared/kubeconfig --watch`.
5. Once pods are runing, curl local machine IP with its NodePort exposed on port 32222. You can use local IP of any of the master/nodes, so any of these three commands should work
- master `curl 192.168.21.100:32222`
- node1  `curl 192.168.21.101:32222`
- node2  `curl 192.168.21.102:32222`

Note: 
- VMs/k8s setup process on my machine with 16 GB of RAM and 
- master's and node IPs are local network IPs and are fixed. In a rare case of these IP adresses being in conflict with some other local service using one of these IPs, there are two places in code requiring IP declaration change: `Vagrantfile` and `scripts/install-master.sh`

# 4. Implementation details 
## 4.1 Repository structure
- `myrevproxy` - directory containing simple helm chart with reverse proxy to `http://ifconfig.me`
- `scripts` - three scrips installing and configuring kubernetes cluster on the 3 Vagrant-managed VMs
- `shared` - directory that stores temporary files generated during runtime - script for nodes to join cluster master and kubeconfig file to authorize helm install to the cluster
- `Vagrantfile` - file creating VMs and executing bash scripts

## 4.2 Vagrant and Kubernetes setup

Process works as follows: 
- executes Vagrantfile that creates 3 VMs based on "ubuntu/xenial64" box. Process creates VMs named master, node1 and node2) 
- runs 3 shell scripts located in the "scripts" directory that install dependencies and install kubernetes cluster

Master node will play the role of control plane. On the master node the scripts will:
- install Docker
- install kubernetes components (kubelet, kubeadm, kubectl)
- install Calico pod network
- generate master join command with kubeadm token and save it to local repo "shared" directory as master-join-command.sh file
- generate kubeconfig file and save it also to local repo "shared" directory (you will use it later with helm)

On the worker nodes the scripts will:
- install Docker
- install kubernetes components (kubelet, kubeadm, kubectl)
- use script "shared/master-join-command.sh" to join worker node to master with 
## 4.3 Reverse proxy implementation
Local helm chart was created simply using `helm create myrevproxy` command and then a few configuration items were added.
The `helm create command` by default creates sample helm chart using Nginx web server so that was the obvious choice for reverse proxy as well.

Key customized elements of the helm chart in the `myrevproxy` directory are the following:
- `values.yaml` - declares to use nginx Dockerhub repository and to expose service as a NodePort 32222 (and route it internally to port 80)
- `deployment.yaml` - declares volume `nginx-conf-volume` that is really a ConfigMap. Mounts this volume to the Nginx container thus allowing nginx to read customized configuration
- `configmap.yaml` - contains `nginx.conf` configuration data element. This will configure nginx to internally listen on port `80` and work as a reverse proxy to `http://ifconfig.me/`. If you want to change this origin, do it here and redeploy everything.

Note that the install command:
`helm install myrevproxy myrevproxy/ --values myrevproxy/values.yaml --kubeconfig shared/kubeconfig` utilizes `shared/kubeconfig` file generated by the cluster in the previous step to authenticate to the cluster. This is created dynamically every time a new cluster is created.
