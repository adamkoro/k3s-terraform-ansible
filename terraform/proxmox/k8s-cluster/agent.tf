resource "proxmox_vm_qemu" "adamkoro-worker" {
  count       = 3
  target_node = "proxmox-1"
  vmid        = "12${count.index}"
  name        = "adamkoro-agent-${count.index + 1}"
  cores       = 4
  sockets     = 1
  cpu         = "host"
  memory      = 4096
  agent       = 1
  onboot      = true
  scsihw      = "virtio-scsi-pci"
  full_clone  = false
  boot        = "cdn"
  bootdisk    = "virtio0"
  clone       = "template"

  provisioner "local-exec" {
    command = "while ! nc -q0 192.168.1.3${count.index + 1} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '192.168.1.3${count.index + 1},' --private-key ${var.ssh_private_key} agent_setup.yaml"
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
  # kubelet
  disk {
    storage = "samsung-1"
    type    = "virtio"
    size    = "20G"
  }
  # rancher
  disk {
    storage = "samsung-2"
    type    = "virtio"
    size    = "16G"
  }
  # longhorn
  disk {
    storage = "toshiba-1"
    type    = "virtio"
    size    = "64G"
  }

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  os_type      = "cloud-init"
  ipconfig0    = "ip=192.168.1.3${count.index + 1}/24,gw=192.168.1.254"
  searchdomain = var.cloud_init_search_domain
  nameserver   = var.cloud_init_nameserver
  ciuser       = var.cloud_init_username
  cipassword   = var.cloud_init_password
  sshkeys      = var.cloud_init_pub_ssh_key
}
