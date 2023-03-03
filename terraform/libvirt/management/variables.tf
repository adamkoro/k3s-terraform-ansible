variable "ssh_private_key" {
  type = string
}

variable "control-plane_vm_count" {
  default = 1
  type    = number
}

variable "control-plane_domain_name" {
  type = string
}


variable "cloud_init_username" {
  type = string
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

variable "kubelet_data_volume_pool" {
  type = string
}

variable "rancher_data_volume_pool" {
  type = string
}

variable "vm_ip_range" {
  type = string
}
