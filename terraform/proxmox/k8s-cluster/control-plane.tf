resource "proxmox_vm_qemu" "adamkoro-cp" {
  count       = 1
  target_node = "proxmox-1"
  vmid        = "11${count.index + 5}"
  name        = "adamkoro-cp-${count.index + 1}"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 2048
  agent       = 1
  onboot      = true
  scsihw      = "virtio-scsi-pci"
  full_clone  = false
  boot        = "cdn"
  bootdisk    = "virtio0"
  clone       = "template"

  provisioner "local-exec" {
    command = "while ! nc -q0 192.168.1.2${count.index + 6} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '192.168.1.2${count.index + 6},' --private-key ${var.ssh_private_key} control-plane_setup.yaml"
  }

  # Root
  disk {
    storage = "kingston-1"
    type    = "virtio"
    size    = "12G"
  }
  # Cloudinit
  disk {
    storage = "kingston-1"
    type    = "sata"
    size    = "4M"
  }
  # swap
  disk {
    storage = "nvme-1"
    type    = "virtio"
    size    = "1G"
  }
  # kubelet
  disk {
    storage = "samsung-1"
    type    = "virtio"
    size    = "16G"
  }
  # rancher
  disk {
    storage = "samsung-2"
    type    = "virtio"
    size    = "16G"
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  os_type      = "cloud-init"
  ipconfig0    = "ip=192.168.1.2${count.index + 6}/24,gw=192.168.1.254"
  searchdomain = var.cloud_init_search_domain
  nameserver   = var.cloud_init_nameserver
  ciuser       = var.cloud_init_username
  cipassword   = var.cloud_init_password
  sshkeys      = var.cloud_init_pub_ssh_key
}
