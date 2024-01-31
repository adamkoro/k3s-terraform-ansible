data "template_file" "cloud_init_management_template" {
  count    = var.vm_count
  template = file("${path.module}/cloud-init_template.tftpl")
  vars = {
    ssh_key  = var.cloud_init_pub_ssh_key
    username = var.cloud_init_username
    password = var.cloud_init_password
    hostname = "${var.proxmox_vm_name}-${count.index + 1}"
    domain   = var.cloud_init_domain
  }
}

resource "local_file" "cloud_init_management_local" {
  count    = var.vm_count
  content  = element(data.template_file.cloud_init_management_template.*.rendered, count.index)
  filename = "${path.module}/files/cloud_init_${var.proxmox_vm_name}-${count.index+1}.cfg"
}

resource "null_resource" "cloud_init_management" {
  count = var.vm_count
  connection {
    type        = "ssh"
    user        = var.proxmox_user
    private_key = file(var.proxmox_private_key)
    host        = var.proxmox_host
  }

  provisioner "file" {
    source      = element(local_file.cloud_init_management_local.*.filename, count.index)
    destination = "${var.cloudinit_host_pool_path}/snippets/cloud_init_${var.proxmox_vm_name}-${count.index+1}.yml"
  }
}