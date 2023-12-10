resource "proxmox_vm_qemu" "management_control_plane" {
    count       = var.vm_count
    target_node = var.proxmox_target_node
    name        = "${var.proxmox_vm_name}-${count.index + 1}"
    cores       = 4
    sockets     = 1
    cpu         = "kvm64"
    memory      = 4096
    agent       = 1
    onboot      = true
    scsihw      = "lsi"
    full_clone  = true
    boot        = "cdn"
    bootdisk    = "scsi0"
    clone       = var.proxmox_template_name
    # Root
    disk {
        storage = var.proxmox_root_pool
        type    = "scsi"
        size    = "20G"
        ssd = 1
    }
    # Swap
    disk {
        storage = var.proxmox_swap_pool
        type    = "scsi"
        size    = "1G"
        ssd = 1
    }
    # Rancher
    disk {
        storage = var.proxmox_rancher_pool
        type    = "scsi"
        size    = "25G"
        ssd = 1
    }
    # Kubelet
    disk {
        storage = var.proxmox_kubelet_pool
        type    = "scsi"
        size    = "30G"
        ssd = 1
    }
    # Longhorn
    disk {
        storage = var.proxmox_longhorn_pool
        type    = "scsi"
        size    = "100G"
        ssd = 1
    }
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    os_type = "cloud-init"
    cloudinit_cdrom_storage = "${var.proxmox_cloudinit_pool}"
    ipconfig0 = "ip=${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask},gw=${var.cloud_init_gateway}"
    cicustom = "user=${var.proxmox_cloudinit_pool}:snippets/cloud_init_mgmt-${count.index+1}.yml"

    provisioner "local-exec" {
        command = "while ! nc -q0 ${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook control_plane_setup.yaml -i '${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase},' --private-key ${var.ansbile_private_key} -e ansible_user=${var.cloud_init_username}"
    }
}