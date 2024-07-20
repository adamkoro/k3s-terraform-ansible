resource "proxmox_vm_qemu" "management_control_plane" {
    count       = var.vm_count
    target_node = var.proxmox_target_node
    name        = "${var.proxmox_vm_name}-cp-${count.index + 1}"
    vmid          = "20${count.index + 1}"
    cores       = 6
    sockets     = 1
    cpu         = "host"
    memory      = 8192
    agent       = 1
    onboot      = true
    scsihw      = "virtio-scsi-single"
    full_clone  = var.proxmox_vm_full_clone
    startup     = "order=1"
    bootdisk    = "scsi0"
    clone       = var.proxmox_template_name
    disks {
        sata {
            sata0 {
                cdrom {
                    iso = proxmox_cloud_init_disk.cp_ci[count.index].id
                }
            }
        }
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
            # longhorn
            virtio3 {
                disk {
                    storage = var.proxmox_longhorn_pool
                    size = var.proxmox_longhorn_pool_size
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
        bridge = "mgmt"
        model  = "virtio"
    }
    provisioner "local-exec" {
        command = "while ! nc -q0 ${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook control_plane_setup.yaml -i '${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase},' --private-key ${var.ansbile_private_key} -e ansible_user=${var.cloud_init_username}"
    }
}