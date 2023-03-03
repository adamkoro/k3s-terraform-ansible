resource "libvirt_domain" "control-plane" {
  count = var.control-plane_vm_count
  name  = "${var.control-plane_domain_name}-${count.index + 1}"
  cpu {
    mode = "host-passthrough"
  }
  autostart = true
  vcpu      = 4
  memory    = 3072
  machine   = "q35"
  xml {
    xslt = file("cdrom-model.xsl")
  }
  disk {
    volume_id = element(libvirt_volume.control-plane_root_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.control-plane_swap_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.control-plane_kubelet_data_disk.*.id, count.index)
  }
  disk {
    volume_id = element(libvirt_volume.control-plane_rancher_data_disk.*.id, count.index)
  }
  network_interface {
    bridge = "br0"
  }
  cloudinit = element(libvirt_cloudinit_disk.control-plane_cloud_init.*.id, count.index)

  provisioner "local-exec" {
    command = "while ! nc -q0 ${var.vm_ip_range}.1${count.index + 6} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${var.vm_ip_range}.1${count.index + 6},' --private-key ${var.ssh_private_key} control-plane_setup.yaml"
  }
}

resource "libvirt_volume" "control-plane_root_disk" {
  name           = "${var.control-plane_domain_name}-${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  base_volume_id = var.base_root_volume_path

  count = var.control-plane_vm_count
}

resource "libvirt_volume" "control-plane_swap_disk" {
  name  = "${var.control-plane_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 536870912
  count = var.control-plane_vm_count
}

resource "libvirt_volume" "control-plane_kubelet_data_disk" {
  name  = "${var.control-plane_domain_name}-${count.index + 1}-kubelet.qcow2"
  pool  = var.kubelet_data_volume_pool
  count = var.control-plane_vm_count
  size  = 16106127360
}

resource "libvirt_volume" "control-plane_rancher_data_disk" {
  name  = "${var.control-plane_domain_name}${count.index + 1}-rancher.qcow2"
  pool  = var.rancher_data_volume_pool
  count = var.control-plane_vm_count
  size  = 21474836480
}

resource "libvirt_cloudinit_disk" "control-plane_cloud_init" {
  pool           = var.root_volume_pool
  name           = "${var.control-plane_domain_name}${count.index + 1}-cloud-init.iso"
  count          = var.control-plane_vm_count
  user_data      = <<EOF
  #cloud-config
hostname: ${var.control-plane_domain_name}-${count.index + 1}
fqdn: ${var.control-plane_domain_name}-${count.index + 1}.adamkoro.local
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
write_files:
  - path: /etc/sysctl.d/99-swappiness.conf
    content: |
      vm.swappiness=5
  - path: /etc/pki/trust/anchors/adamkoro.local.crt
    content: |
      -----BEGIN CERTIFICATE-----
      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
      -----END CERTIFICATE-----
EOF
  network_config = <<EOF
version: 1
config:
    - type: physical
      name: eth0
      subnets:
      - type: static
        address: '${var.vm_ip_range}.1${count.index + 6}'
        netmask: '255.255.255.0'
        gateway: '192.168.1.254'
    - type: nameserver
      address:
      - '${var.cloud_init_nameserver}'
      search:
      - '${var.cloud_init_search_domain}'
EOF
}
