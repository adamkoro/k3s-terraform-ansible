# **k3s-terraform-ansible** for make kubernetes install and config easy


## **Branches**
- **main** -> Maintained version of the repo
- **k3s-postgres** -> Old version which uses external PostgresSQL for K3S database

## Branch Info
### Terraform
- Terraform provider made for Libvirt (qemu/kvm) and Proxmox.
- Each cluster section contains own Terraform directory and setting. Example: etcd cluster has own playbook and k3s management and downstream has own too.
- Q35 vm fix get from this issue, thank you so much: https://github.com/dmacvicar/terraform-provider-libvirt/issues/885#issuecomment-967143916

### Ansible
- Each cluster section contains own playbook, like in Terraform.

### Features
- All of the required kubernetes app deployed by manifest files.


## Management cluster
#### Architecture 
- 3 node install
  - All the nodes are control plane

- [Ansible playbook](ansible/management/)
- [Terraform](terraform/libvirt/management/)

### Features
- Rancher
- Longhorn
- Cert-manager
- Nginx ingress controller
- Kube-vip
- Metallb

## Downstream cluster

#### Architecture
- 9 node install
  - 2 node proxy
  - 3 node etcd
  - 1 node control plane 
  - 3 node agent

- [Ansible playbook](ansible/downstream/)
- [Terraform](terraform/libvirt/downstream/)

### Features
- Crm cluster with pacemaker and corosync for nginx loadbalancer
- Metallb for loadbalancer service
- Harbor for private registry
- Longhorn for storage
- Ingrees-nginx for ingress controller
- Cert-manager for certificate management
