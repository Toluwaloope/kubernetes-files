!#/bin/bash

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf

##enable the kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

##set system level settings for network function====
cat <<EOF | sudo tee/etc/sysctl.d/99-kubernetes-cri.conf

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
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

##install kubernetes packages ====
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00

##prevent installed kubernetes packages from updating====
sudo apt-mark hold kubelet kubeadm kubectl

##Setup kubernetes cluster only on the control plane====
##sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0