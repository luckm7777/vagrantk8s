#!/bin/bash
# Create cluster using kubeadm
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
sudo kubeadm config images pull
sudo kubeadm init --apiserver-advertise-address=192.168.21.100 --control-plane-endpoint=192.168.21.100 --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Install Calico pod network
sudo kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
sudo kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
# Clean up shared directory to delete old files
rm -r /vagrant/shared/*
# Get token to join nodes
kubeadm token create --print-join-command > /vagrant/shared/master-join-command.sh
# Share kubeconfig file to Vagrant dir
cp $HOME/.kube/config /vagrant/shared/kubeconfig