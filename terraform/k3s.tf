resource "proxmox_vm_qemu" "database" {
    count = 1
    target_node = "proxmox-1"
    vmid = "10${count.index}"
    name = "database-${count.index + 1}"
    cores = 2
    sockets = 1
    cpu = "host"    
    memory = 1024
    balloon = 512
    agent = 1
    onboot = true 
    scsihw = "virtio-scsi-pci"
    full_clone = false
    boot= "cdn"
    bootdisk = "scsi0"

    clone = "template"
    # Root
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "16G"
        ssd = 0
    }
    # Cloudinit
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "4M"
        ssd = 0
    }
    # Database
    disk {
        storage = "local-lvm"
        type = "scsi"
        size = "8G"
        ssd = 1
    }

    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.2${count.index}/24,gw=192.168.1.254"
    ciuser = var.cloudinit_username
    cipassword = var.cloud_init_password
    sshkeys = var.cloud_init_pub_ssh_key
}

resource "proxmox_vm_qemu" "master" {
    count = var.vm_count
    target_node = "proxmox-1"
    vmid = "20${count.index + 1}"
    name = "master-${count.index + 1}"
    cores = 2
    sockets = 1
    cpu = "host"    
    memory = 2048
    balloon = 1024
    agent = 1
    onboot = true 
    scsihw = "virtio-scsi-pci"
    full_clone = false
    boot= "cdn"
    bootdisk = "scsi0"

    clone = "template"
    # Root
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "16G"
        ssd = 0
    }
    # Cloudinit
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "4M"
        ssd = 0
    }
    # Rancher
    disk {
        storage = "ssd-thin"
        type = "scsi"
        size = "16G"
        ssd = 1
    }

    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.2${count.index + 1}/24,gw=192.168.1.254"
    ciuser = var.cloudinit_username
    cipassword = var.cloud_init_password
    sshkeys = var.cloud_init_pub_ssh_key
}

resource "proxmox_vm_qemu" "worker" {
    count = var.vm_count
    target_node = "proxmox-1"
    vmid = "30${count.index + 1}"
    name = "worker-${count.index + 1}"
    cores = 2
    sockets = 1
    cpu = "host"    
    memory = 4096
    balloon = 1024
    agent = 1
    onboot = true 
    scsihw = "virtio-scsi-pci"
    full_clone = false
    boot= "cdn"
    bootdisk = "scsi0"

    clone = "template"
    # Root
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "16G"
        ssd = 0
    }
    # Cloudinit
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "4M"
        ssd = 0
    }
    # Rancher
    disk {
        storage = "ssd-thin"
        type = "scsi"
        size = "32G"
        ssd = 1
    }

    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.3${count.index + 1}/24,gw=192.168.1.254"
    ciuser = var.cloudinit_username
    cipassword = var.cloud_init_password
    sshkeys = var.cloud_init_pub_ssh_key
}
resource "proxmox_vm_qemu" "storage" {
    count = var.vm_count
    target_node = "proxmox-1"
    vmid = "40${count.index + 1}"
    name = "storage-${count.index + 1}"
    cores = 2
    sockets = 1
    cpu = "host"    
    memory = 1024
    balloon = 512
    agent = 1
    onboot = true 
    scsihw = "virtio-scsi-pci"
    full_clone = false
    boot= "cdn"
    bootdisk = "scsi0"

    clone = "template"
    # Root
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "16G"
        ssd = 0
    }
    # Cloudinit
    disk {
        storage = "hdd-thin"
        type = "scsi"
        size = "4M"
        ssd = 0
    }
    # Longhron
    disk {
        storage = "local-lvm"
        type = "scsi"
        size = "32G"
        ssd = 1
    }
    # Rancher
    disk {
        storage = "ssd-thin"
        type = "scsi"
        size = "16G"
        ssd = 1
    }

    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=192.168.1.3${5 + count.index}/24,gw=192.168.1.254"
    ciuser = var.cloudinit_username
    cipassword = var.cloud_init_password
    sshkeys = var.cloud_init_pub_ssh_key
}