resource "proxmox_vm_qemu" "adamkoro-master" {
  count       = 3
  target_node = "proxmox-1"
  vmid        = "11${count.index + 4}"
  name        = "adamkoro-master${count.index + 1}"
  cores       = 2
  sockets     = 1
  cpu         = "EPYC-IBPB"
  memory      = 1024
  agent       = 1
  onboot      = true
  scsihw      = "virtio-scsi-pci"
  full_clone  = false
  boot        = "cdn"
  bootdisk    = "scsi0"

  clone = "template"
  # Root
  disk {
    storage = "toshiba-3"
    type    = "scsi"
    size    = "16G"
    ssd     = 0
    cache   = "writeback"
  }
  # Cloudinit
  disk {
    storage = "toshiba-3"
    type    = "scsi"
    size    = "4M"
    ssd     = 0
  }
  # swap
  disk {
    storage = "nvme-1"
    type    = "scsi"
    size    = "1G"
    ssd     = 1
  }
  # kubelet
  disk {
    storage = "local-lvm"
    type    = "scsi"
    size    = "32G"
    ssd     = 1
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
