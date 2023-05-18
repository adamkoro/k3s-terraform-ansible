############
# Proxy
############
resource "libvirt_volume" "proxy_root_disk" {
  name   = "${var.proxy_domain_name}-${count.index + 1}-root.qcow2"
  pool   = var.root_volume_pool
  source = var.base_root_volume_path
  count  = var.proxy_vm_count
}

resource "libvirt_volume" "proxy_swap_disk" {
  name  = "${var.proxy_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 536870912
  count = var.proxy_vm_count
}

############
# Etcd
############
resource "libvirt_volume" "etcd_root_disk" {
  name   = "${var.etcd_domain_name}-${count.index + 1}-root.qcow2"
  pool   = var.root_volume_pool
  source = var.base_root_volume_path
  count  = var.etcd_vm_count
}

resource "libvirt_volume" "etcd_swap_disk" {
  name  = "${var.etcd_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 536870912
  count = var.etcd_vm_count
}

resource "libvirt_volume" "etcd_data_disk" {
  name  = "${var.etcd_domain_name}-${count.index + 1}-data.qcow2"
  pool  = var.etcd_data_volume_pool
  count = var.etcd_vm_count
  size  = 10737418240
}

############
# Control Plane
############
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

############
# Agent
############
resource "libvirt_volume" "agent_root_disk" {
  name           = "${var.agent_domain_name}${count.index + 1}-root.qcow2"
  pool           = var.root_volume_pool
  source = var.base_root_volume_path
  count          = var.agent_vm_count
}

resource "libvirt_volume" "agent_swap_disk" {
  name  = "${var.agent_domain_name}-${count.index + 1}-swap.qcow2"
  pool  = var.swap_volume_pool
  size  = 536870912
  count = var.agent_vm_count
}

resource "libvirt_volume" "agent_kubelet_data_disk" {
  name  = "${var.agent_domain_name}-${count.index + 1}-kubelet.qcow2"
  pool  = var.kubelet_data_volume_pool
  count = var.agent_vm_count
  size  = 32212254720
}

resource "libvirt_volume" "agent_rancher_data_disk" {
  name  = "${var.agent_domain_name}-${count.index + 1}-rancher.qcow2"
  pool  = var.rancher_data_volume_pool
  count = var.agent_vm_count
  size  = 21474836480
}

resource "libvirt_volume" "agent_longhorn_data_disk" {
  name  = "${var.agent_domain_name}-${count.index + 1}-longhorn.qcow2"
  pool  = var.longhorn_data_volume_pool
  count = var.agent_vm_count
  size  = 85899345920
}