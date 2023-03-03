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
- 1 node install
  - Single node K3S install

- **UNDER DEVELOP!** [Ansible playbook](ansible/management/)
- [Terraform](terraform/libvirt/management/)

### Features
- Rancher instance

## Downstream cluster

#### Architecture
- 9 node install
  - 2 node proxy
  - 3 node etcd
  - 1 node control plane 
  - 3 node agent

### Features
- Crm cluster with pacemaker and corosync for nginx loadbalancer
- Metallb for loadbalancer service
- Harbor for private registry
- Longhorn for storage
- Ingrees-nginx for ingress controller
- Cert-manager for certificate management


## External HA etcd cluster with loadbalancer

### **IMPORTANT!** I'm not use external etcd cluster anymore, so I leave it in , but I'm not maintain it.
- [Ansible playbook](ansible/downstream/etcd-cluster/)
- [Terraform](terraform/proxmox/etcd-cluster/)

#### Architecture
- 4 node install
    - 1 loadbalancer
    - 3 etcd hosts
    - Loadbalancer: simple nginx tcp loadbalancer
        - Config: [nginx.conf](ansible/downstream/etcd-cluster/roles/nginx/templates/nginx.conf.j2)
    - Etcd hosts: etcd configure by systemd service
        - Config: [etcd.service](ansible/downstream/etcd-cluster/roles/etcd/templates/etcd.service.j2)