resource "libvirt_domain" "etcd" {
  count = var.etcd_vm_count
  name  = "${var.etcd_domain_name}-${count.index + 1}"
  cpu {
    mode = "host-passthrough"
  }
  machine = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  autostart = true
  vcpu      = 1
  memory    = 512
  disk {
    volume_id = element(libvirt_volume.etcd_root_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.etcd_swap_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.etcd_data_disk.*.id, count.index)
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = element(libvirt_cloudinit_disk.cloud_init.*.id, count.index)

  provisioner "local-exec" {
    command = "while ! nc -q0 192.168.1.2${count.index + 3} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '192.168.1.2${count.index + 3},' --private-key ${var.ssh_private_key} etcd_setup.yaml"
  }
}

resource "libvirt_volume" "etcd_root_disk" {
  name           = "${var.etcd_domain_name}-${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = var.base_root_volume_path
  count          = var.etcd_vm_count
}

resource "libvirt_volume" "etcd_swap_disk" {
  name  = "${var.etcd_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 1073741824
  count = var.etcd_vm_count
}

resource "libvirt_volume" "etcd_data_disk" {
  name  = "${var.etcd_domain_name}-${count.index + 1}-data.qcow2"
  pool  = var.etcd_data_volume_pool
  count = var.etcd_vm_count
  size  = 10737418240
}

resource "libvirt_cloudinit_disk" "cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.etcd_domain_name}${count.index + 1}-cloud-init.iso"
  count          = var.etcd_vm_count
  user_data      = <<EOF
#cloud-config
hostname: ${var.etcd_domain_name}-${count.index + 1}
fqdn: ${var.etcd_domain_name}-${count.index + 1}.adamkoro.local
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
  - sysctl vm.swappiness=1
EOF
  network_config = <<EOF
version: 1
config:
    - type: physical
      name: eth0
      subnets:
      - type: static
        address: '192.168.1.2${count.index + 3}'
        netmask: '255.255.255.0'
        gateway: '192.168.1.254'
    - type: nameserver
      address:
      - '${var.cloud_init_nameserver}'
      search:
      - '${var.cloud_init_search_domain}'
EOF
}
