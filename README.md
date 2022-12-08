# **k3s-terraform-ansible** for make kubernetes install and config easy


## **Branches**
- **main** -> Maintained version of the repo
- **k3s-postgres** -> Old version which uses external PostgresSQL for K3S database

## Branch Info
### Terraform
- Terraform provider made only for Proxmox (I'm using this in my homelab for hypervisor).
- Each cluster section contains own Terraform directory and setting. Example: etcd cluster has own playbook and k3s has own too.
- Q35 vm fix get from this issue, thank you so much: https://github.com/dmacvicar/terraform-provider-libvirt/issues/885#issuecomment-967143916

### Ansible
- Each cluster section contains own playbook, like in Terraform.

### Features
- **External HA etcd cluster with loadbalancer** -> [Terraform](terraform/etcd-cluster/) and [Ansible](ansible/etcd-cluster/) install. 
    - Architecture -> 4 node install
        - 1 loadbalancer
        - 3 etcd hosts
    - Loadbalancer: simple nginx tcp loadbalancer
        - Config: [nginx.conf](ansible/etcd-cluster/roles/nginx/templates/nginx.conf.j2)
    - Etcd hosts: etcd configure by systemd service
        - Config: [etcd.service](ansible/etcd-cluster/roles/etcd/templates/etcd.service.j2)
