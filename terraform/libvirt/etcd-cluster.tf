resource "libvirt_domain" "etcd_cluster" {
  count = var.etcd_cluster_vm_count
  name  = "${var.etcd_cluster_domain_name}${count.index + 1}"
  cpu {
    mode = "host-model"
  }
  machine = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  autostart = true
  vcpu      = 2
  memory    = 512
  disk {
    volume_id = element(libvirt_volume.root_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.swap_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.etcd_data_disk.*.id, count.index)
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = element(libvirt_cloudinit_disk.cloud_init.*.id, count.index)
}

resource "libvirt_volume" "root_disk" {
  name           = "${var.etcd_cluster_domain_name}${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
  count          = var.etcd_cluster_vm_count
}

resource "libvirt_volume" "swap_disk" {
  name           = "${var.etcd_cluster_domain_name}${count.index + 1}-swap.qcow2"
  pool           = var.swap_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template-swap.qcow2"
  count          = var.etcd_cluster_vm_count
}

resource "libvirt_volume" "etcd_data_disk" {
  name  = "${var.etcd_cluster_domain_name}${count.index + 1}-data.qcow2"
  pool  = var.etcd_data_volume_pool
  count = var.etcd_cluster_vm_count
  size  = 10737418240
}

resource "libvirt_cloudinit_disk" "cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.etcd_cluster_domain_name}${count.index + 1}-cloud-init.iso"
  count          = var.etcd_cluster_vm_count
  user_data      = <<EOF
#cloud-config
hostname: ${var.etcd_cluster_domain_name}${count.index + 1}
fqdn: ${var.etcd_cluster_domain_name}${count.index + 1}.adamkoro.local
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
bootcmd:
  - sysctl vm.swappiness=5
EOF
  network_config = <<EOF
version: 2
ethernets:
  eth0:
    addresses: 
    - 192.168.1.2${count.index + 1}/24
    gateway4: 192.168.1.254
    nameservers:
      addresses: [ ${var.cloud_init_nameserver} ]
      search: [ ${var.cloud_init_search_domain} ]
EOF
}
