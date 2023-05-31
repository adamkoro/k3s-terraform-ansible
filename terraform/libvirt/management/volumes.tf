resource "libvirt_volume" "control-plane_root_disk" {
  name   = "${var.control-plane_domain_name}-${count.index + 1}-root.qcow2"
  pool   = var.root_volume_pool
  source = var.base_root_volume_path
  count  = var.control-plane_vm_count
}

resource "libvirt_volume" "control-plane_swap_disk" {
  name  = "${var.control-plane_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 536870912
  count = var.control-plane_vm_count
}

resource "libvirt_volume" "control-plane_kubelet_data_disk" {
  name  = "${var.control-plane_domain_name}-${count.index + 1}-kubelet.qcow2"
  pool  = var.kubelet_data_volume_pool
  count = var.control-plane_vm_count
  size  = 16106127360
}

resource "libvirt_volume" "control-plane_rancher_data_disk" {
  name  = "${var.control-plane_domain_name}${count.index + 1}-rancher.qcow2"
  pool  = var.rancher_data_volume_pool
  count = var.control-plane_vm_count
  size  = 21474836480
}

resource "libvirt_volume" "control-plane_longhorn_data_disk" {
  name  = "${var.control-plane_domain_name}-${count.index + 1}-longhorn.qcow2"
  pool  = var.longhorn_data_volume_pool
  count = var.control-plane_vm_count
  size  = 53687091200
}