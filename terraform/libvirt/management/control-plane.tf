resource "libvirt_domain" "control-plane" {
  count = var.control-plane_vm_count
  name  = "${var.control-plane_domain_name}-${count.index + 1}"
  cpu {
    mode = "host-passthrough"
  }
  autostart = true
  vcpu      = 4
  memory    = 4096
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