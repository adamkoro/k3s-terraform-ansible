#resource "libvirt_volume" "os_image" {
#  name   = "opensuse-template.qcow2"
#  pool   = var.root_volume_pool
#  source = "/mnt/toshiba-3/vm-images/opensuse-template.qcow2"
#  format = "qcow2"
#}
#
#resource "libvirt_volume" "os_swap" {
#  name   = "opensuse-template-swap.qcow2"
#  pool   = var.root_volume_pool
#  source = "/mnt/toshiba-3/vm-images/opensuse-template-swap.qcow2"
#  format = "qcow2"
#}
