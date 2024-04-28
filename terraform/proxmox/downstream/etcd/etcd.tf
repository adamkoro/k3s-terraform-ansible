resource "proxmox_vm_qemu" "etcd" {
    count       = var.vm_count
    target_node = var.proxmox_target_node
    name        = "${var.proxmox_vm_name}-etcd-${count.index + 1}"
    cores       = 2
    sockets     = 1
    cpu         = "host"
    memory      = 2048
    agent       = 1
    onboot      = true
    scsihw      = "virtio-scsi-single"
    full_clone  = true

    bootdisk    = "scsi0"
    startup     = "order=2"
    clone       = var.proxmox_template_name
disks {
        scsi {
            # Root
            scsi0 {
                disk {
                    storage = var.proxmox_root_pool
                    size = var.proxmox_root_pool_size
                    iothread = true
                    emulatessd = true
                    asyncio = "native"
                }
            }
        }
        virtio {
            # swap
            virtio0 {
                disk {
                    storage = var.proxmox_swap_pool
                    size = var.proxmox_swap_pool_size
                    iothread = true
                    asyncio = "native"
                }
            }
            # rancher
            virtio1 {
                disk {
                    storage = var.proxmox_rancher_pool
                    size = var.proxmox_rancher_pool_size
                    iothread = true
                    asyncio = "native"
                }
            }
            # kubelet
            virtio2 {
                disk {
                    storage = var.proxmox_kubelet_pool
                    size = var.proxmox_kubelet_pool_size
                    iothread = true
                    asyncio = "native"
                }
            }
        }
    }
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    network {
        bridge = "vmbr1"
        model  = "virtio"
    }
    network {
        bridge = "adamkoro"
        model  = "virtio"
    }
    os_type = "cloud-init"
    cloudinit_cdrom_storage = var.proxmox_cloudinit_pool
    ipconfig0 = "ip=${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask},gw=${var.cloud_init_gateway0}"
    ipconfig1 = "ip=${var.cloud_init_ip_pool1}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask},gw=${var.cloud_init_gateway1}"
    ipconfig2 = "ip=${var.cloud_init_ip_pool2}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask}"
    cicustom = "user=${var.proxmox_cloudinit_pool}:snippets/cloud_init_${var.proxmox_vm_name}-etcd-${count.index + 1}.yml"
    # Check if vm ssh port is open
    provisioner "local-exec" {
        command = "while ! nc -q0 ${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
    }
    # Run ansible playbook
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook setup.yaml -i '${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase},' --private-key ${var.ansbile_private_key} -e ansible_user=${var.cloud_init_username}"
    }
}