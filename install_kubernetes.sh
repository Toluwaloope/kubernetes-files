#!bin/bash

sudo echo "overlay" >> /etc/modules-load.d/containerd.conf
sudo echo "br_netfilter" >> /etc/modules-load.d/containerd.conf
##cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf

#enable the kernel modules

sudo modprobe overlay
sudo modprobe br_netfilter

##set system level settings for network function====
#cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
sudo echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf



##restart system to load settings=======
sudo sysctl --system

##update apt repo and install containerd=====
sudo apt-get update && sudo apt-get install -y containerd

##create default config file for containerd===
sudo -p /etc/containerd

##generate config and save it in the new config file ====
sudo containerd config default | sudo tee /etc/containerd/config.xml

##restart containerd to apply settings=======
sudo systemctl restart containerd

##disable swapp on system for kuernetes to work===
sudo swapoff -a

##remove any swap entry in the fstab file incase it is configured to start with system====
sudo sed -i '/ swap / s/^\(."\)$/#\1/g' /etc/fstab

##install required packages for kube=====
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

##add gpg key for kubernetes repository=======
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

##setup kubernetes list ====
#cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update

##install kubernetes packages ====
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00

##prevent installed kubernetes packages from updating====
sudo apt-mark hold kubelet kubeadm kubectl

##Setup kubernetes cluster only on the control plane====
##initialize kubernetes
##sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0

#setup kube-config
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install calico network addon
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

#to get join goken for worker nodes
##kubeadm token create --print-join-command
