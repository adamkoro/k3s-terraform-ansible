resource "libvirt_domain" "etcd_loadbalancer" {
  name = "${var.etcd_cluster_domain_name}-lb"
  cpu {
    mode = "host-model"
  }
  autostart = true
  vcpu      = 2
  memory    = 512
  disk {
    volume_id = libvirt_volume.lb_root_disk.id
    scsi      = true
  }
  disk {
    volume_id = libvirt_volume.lb_swap_disk.id
    scsi      = true
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = libvirt_cloudinit_disk.lb_cloud_init.id
}

resource "libvirt_volume" "lb_root_disk" {
  name           = "${var.etcd_cluster_domain_name}-lb-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
}

resource "libvirt_volume" "lb_swap_disk" {
  name           = "${var.etcd_cluster_domain_name}-lb-swap.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template-swap.qcow2"
}

resource "libvirt_cloudinit_disk" "lb_cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.etcd_cluster_domain_name}-lb-cloud-init.iso"
  user_data      = <<EOF
#cloud-config
hostname: ${var.etcd_cluster_domain_name}-lb
fqdn: ${var.etcd_cluster_domain_name}-lb.adamkoro.local
manage_etc_hosts: true
users:
  - name: ${var.cloud_init_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users
    home: /home/${var.cloud_init_username}
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - ${file("${var.cloud_init_sshkey}")}
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    ${var.cloud_init_username}:${var.cloud_init_password}
  expire: False
runcmd:
  - sysctl vm.swappiness=5
EOF
  network_config = <<EOF
version: 2
ethernets:
  eth1:
    addresses: 
    - 192.168.1.20/24
    gateway4: 192.168.1.254
    nameservers:
      addresses: [ 192.168.1.10 ]
      search: [ adamkoro.local ]
EOF
}
