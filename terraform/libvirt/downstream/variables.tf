variable "ssh_private_key" {
  type = string
}

variable "proxy_vm_count" {
  default = 2
  type    = number
}

variable "proxy_domain_name" {
  type = string
}

variable "etcd_vm_count" {
  default = 3
  type    = number
}

variable "etcd_domain_name" {
  type = string
}

variable "control-plane_vm_count" {
  default = 1
  type    = number
}

variable "control-plane_domain_name" {
  type = string
}

variable "agent_vm_count" {
  default = 3
  type    = number
}

variable "agent_domain_name" {
  type = string
}

variable "cloud_init_username" {
}

variable "cloud_init_password" {
  type = string
}

variable "cloud_init_sshkey" {
  type = string
}

variable "cloud_init_nameserver" {
  type = string
}

variable "cloud_init_search_domain" {
  type = string
}

variable "base_root_volume_path" {
  type = string
}

variable "root_volume_pool" {
  type = string
}

variable "swap_volume_pool" {
  type = string
}

variable "etcd_data_volume_pool" {
  type = string
}

variable "kubelet_data_volume_pool" {
  type = string
}

variable "rancher_data_volume_pool" {
  type = string
}

variable "longhorn_data_volume_pool" {
  type = string
}

variable "cloud_init_disk_pool" {
  type = string
}

