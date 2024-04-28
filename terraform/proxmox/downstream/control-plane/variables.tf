## Default
variable "vm_count" {
  default     = 3
  description = "Number of VMs to create"
}
variable "proxmox_vm_name" {
  description = "Name of VMs to create"
}
variable "proxmox_template_name" {
  type        = string
  description = "Proxmox VM template"
}
variable "proxmox_target_node" {
  type        = string
  description = "Proxmox target node"
}
## Cloud-init
variable "cloud_init_username" {
  type        = string
  description = "Username for cloud-init"
}
variable "cloud_init_password" {
  type        = string
  sensitive   = true
  description = "Password for cloud-init"
}
variable "cloud_init_pub_ssh_key" {
  type        = string
  description = "Public SSH key for cloud-init"
}
variable "cloud_init_netmask" {
  type        = string
  description = "Netmask for cloud-init"
}
variable "cloud_init_gateway1" {
  type        = string
  description = "Gateway for cloud-init"
}
variable "cloud_init_ip_pool1" {
  type        = string
  description = "IP pool for cloud-init"
}
variable "cloud_init_gateway2" {
  type        = string
  description = "Gateway for cloud-init"
}
variable "cloud_init_ip_pool2" {
  type        = string
  description = "IP pool for cloud-init"
}
variable "cloud_init_gateway0" {
  type        = string
  description = "Gateway for cloud-init"
}
variable "cloud_init_ip_pool0" {
  type        = string
  description = "IP pool for cloud-init"
}
variable "cloud_init_ip_increase" {
  type        = number
  description = "IP increase for cloud-init"
}
variable "cloud_init_domain" {
  type        = string
  description = "Domain for cloud-init"
}
## Proxmox provider
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}
variable "proxmox_api_token_id" {
  type        = string
  sensitive   = true
  description = "Proxmox API Token ID"
}
variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API Token Secret"
}
## Proxmox storage
variable "proxmox_root_pool" {
  type        = string
  description = "Proxmox root disk pool"
}
variable "proxmox_root_pool_size" {
  type        = number
  description = "Proxmox root disk pool size"
}
variable "proxmox_swap_pool" {
  type        = string
  description = "Proxmox swap disk pool"
}
variable "proxmox_swap_pool_size" {
  type        = number
  description = "Proxmox swap disk pool size"
}
variable "proxmox_rancher_pool" {
  type        = string
  description = "Proxmox rancher disk pool"
}
variable "proxmox_rancher_pool_size" {
  type        = number
  description = "Proxmox rancher disk pool size"
}
variable "proxmox_kubelet_pool" {
  type        = string
  description = "Proxmox kubelet disk pool"
}
variable "proxmox_kubelet_pool_size" {
  type        = number
  description = "Proxmox kubelet disk pool size"
}
variable "proxmox_cloudinit_pool" {
  type = string
  description = "Proxmox cloud-init pool"
  
}
variable "cloudinit_host_pool_path" {
  type = string
  description = "Host pool path for cloud-init snippet"
  
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox user"
}
variable "proxmox_host" {
  type        = string
  description = "Proxmox host"
}
variable "proxmox_private_key" {
  type        = string
  description = "Proxmox private key path"
}

variable "ansbile_private_key" {
  type        = string
  description = "Ansible private key path"
}
