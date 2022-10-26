resource "libvirt_domain" "master" {
  count = var.master_vm_count
  name  = "${var.master_domain_name}${count.index + 1}"
  cpu {
    mode = "host-model"
  }
  autostart = true
  vcpu      = 2
  memory    = 2048
  machine   = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  disk {
    volume_id = element(libvirt_volume.master_root_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.master_swap_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.master_kubelet_data_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.master_rancher_data_disk.*.id, count.index)
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = element(libvirt_cloudinit_disk.master_cloud_init.*.id, count.index)
}

resource "libvirt_domain" "worker" {
  count = var.worker_vm_count
  name  = "${var.worker_domain_name}${count.index + 1}"
  cpu {
    mode = "host-model"
  }
  machine = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  autostart = true
  vcpu      = 4
  memory    = 3072
  disk {
    volume_id = element(libvirt_volume.worker_root_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.worker_swap_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.worker_kubelet_data_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.worker_rancher_data_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.worker_longhorn_data_disk.*.id, count.index)
  }
  network_interface {
    bridge         = "br0"
    wait_for_lease = true
  }
  cloudinit = element(libvirt_cloudinit_disk.worker_cloud_init.*.id, count.index)
}

###############
# Master disks
###############

resource "libvirt_volume" "master_root_disk" {
  name           = "${var.master_domain_name}${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
  count          = var.master_vm_count
}

resource "libvirt_volume" "master_swap_disk" {
  name           = "${var.master_domain_name}${count.index + 1}-swap.qcow2"
  pool           = var.swap_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template-swap.qcow2"
  count          = var.master_vm_count
}

resource "libvirt_volume" "master_kubelet_data_disk" {
  name  = "${var.master_domain_name}${count.index + 1}-kubelet.qcow2"
  pool  = var.kubelet_data_volume_pool
  count = var.master_vm_count
  size  = 16106127360
}

resource "libvirt_volume" "master_rancher_data_disk" {
  name  = "${var.master_domain_name}${count.index + 1}-rancher.qcow2"
  pool  = var.rancher_data_volume_pool
  count = var.master_vm_count
  size  = 21474836480
}

resource "libvirt_cloudinit_disk" "master_cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.master_domain_name}${count.index + 1}-cloud-init.iso"
  count          = var.master_vm_count
  user_data      = <<EOF
#cloud-config
hostname: ${var.master_domain_name}${count.index + 1}
fqdn: ${var.master_domain_name}${count.index + 1}.adamkoro.local
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
    - 192.168.1.2${count.index + 6}/24
    gateway4: 192.168.1.254
    nameservers:
      addresses: [ ${var.cloud_init_nameserver} ]
      search: [ ${var.cloud_init_search_domain} ]
EOF
}

###############
# Worker disks
###############
resource "libvirt_volume" "worker_root_disk" {
  name           = "${var.worker_domain_name}${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
  count          = var.master_vm_count
}

resource "libvirt_volume" "worker_swap_disk" {
  name           = "${var.worker_domain_name}${count.index + 1}-swap.qcow2"
  pool           = var.swap_volume_pool
  base_volume_id = "/mnt/toshiba-3/vm-images/opensuse-template-swap.qcow2"
  count          = var.worker_vm_count
}

resource "libvirt_volume" "worker_kubelet_data_disk" {
  name  = "${var.worker_domain_name}${count.index + 1}-kubelet.qcow2"
  pool  = var.kubelet_data_volume_pool
  count = var.worker_vm_count
  size  = 32212254720
}

resource "libvirt_volume" "worker_rancher_data_disk" {
  name  = "${var.worker_domain_name}${count.index + 1}-rancher.qcow2"
  pool  = var.rancher_data_volume_pool
  count = var.worker_vm_count
  size  = 21474836480
}

resource "libvirt_volume" "worker_longhorn_data_disk" {
  name  = "${var.worker_domain_name}${count.index + 1}-longhorn.qcow2"
  pool  = var.longhorn_data_volume_pool
  count = var.worker_vm_count
  size  = 64424509440
}

resource "libvirt_cloudinit_disk" "worker_cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.worker_domain_name}${count.index + 1}-cloud-init.iso"
  count          = var.worker_vm_count
  user_data      = <<EOF
#cloud-config
hostname: ${var.worker_domain_name}${count.index + 1}
fqdn: ${var.worker_domain_name}${count.index + 1}.adamkoro.local
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
    - 192.168.1.3${count.index + 1}/24
    gateway4: 192.168.1.254
    nameservers:
      addresses: [ ${var.cloud_init_nameserver} ]
      search: [ ${var.cloud_init_search_domain} ]
EOF
}


