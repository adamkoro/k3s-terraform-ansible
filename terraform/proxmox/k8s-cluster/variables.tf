variable "vm_count"{
    default = 3
}

variable "ssh_private_key" {
    type = string
}

variable "cloud_init_username"{
    type = string
}

variable "cloud_init_password"{
    type = string
    sensitive = true
}

variable "cloud_init_pub_ssh_key"{
    type = string
}

variable "cloud_init_search_domain"{
    type = string
}

variable "cloud_init_nameserver"{
    type = string
}

variable "proxmox_api_url"{
    type = string
}

variable "proxmox_api_token_id"{
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret"{
    type = string
    sensitive = true
}

