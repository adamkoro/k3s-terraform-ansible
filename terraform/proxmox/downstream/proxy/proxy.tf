resource "proxmox_vm_qemu" "agent" {
    count       = var.vm_count
    target_node = var.proxmox_target_node
    name        = "${var.proxmox_vm_name}-proxy-${count.index + 1}"
    cores       = 2
    sockets     = 1
    cpu         = "host"
    memory      = 512
    agent       = 1
    onboot      = true
    scsihw      = "virtio-scsi-single"
    full_clone  = true
    boot        = "cdn"
    bootdisk    = "scsi0"
    startup     = "order=1"
    clone       = var.proxmox_template_name
    os_type = "cloud-init"
    # Root
    disk {
        storage = var.proxmox_root_pool
        type    = "scsi"
        size    = var.proxmox_root_pool_size
    }
    # Swap
    disk {
        storage = var.proxmox_swap_pool
        type    = "virtio"
        size    = var.proxmox_swap_pool_size
        format = "qcow2"
        iothread = 1
    }
    # Cloud-init
    cloudinit_cdrom_storage = var.proxmox_cloud_init_pool
    cicustom = "user=${var.proxmox_cloud_init_pool}:snippets/cloud_init_${var.proxmox_vm_name}-proxy-${count.index + 1}.yml"
    # Network
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    ipconfig0 = "ip=${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask},gw=${var.cloud_init_gateway}"
    # Check if vm ssh port is open
    provisioner "local-exec" {
        command = "while ! nc -q0 ${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase} 22 < /dev/null > /dev/null 2>&1; do sleep 10;done"
    }
    # Check if python is installed -- NOT NEEDED
    #provisioner "local-exec" {
    #    command = "while ! ANSIBLE_HOST_KEY_CHECKING=False ansible -i '${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase},' all -m ansible.builtin.shell -a 'command -v python' --private-key ${var.ansbile_private_key} -e ansible_user=${var.cloud_init_username}; do sleep 10;done"
    #}
    # Run ansible playbook
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook setup.yaml -i '${var.cloud_init_ip_pool}${count.index + var.cloud_init_ip_increase},' --private-key ${var.ansbile_private_key} -e ansible_user=${var.cloud_init_username}"
    }
}