resource "proxmox_cloud_init_disk" "proxy_ci" {
  name     = "${var.proxmox_vm_name}-proxy-${count.index + 1}-cloud-init"
  pve_node = var.proxmox_target_node
  storage  = var.proxmox_cloudinit_pool
  count    = var.vm_count

  vendor_data = <<EOT
EOT

  meta_data = <<EOT
instance_id: ${sha1("${var.proxmox_vm_name}-proxy-${count.index + 1}")}
EOT

  user_data = <<EOT
#cloud-config
package_update: false
package_upgrade: false
locale: "en_US.UTF-8"
keyboard:
  layout: "hu"
  variant: ""
users:
- name: ${var.cloud_init_username}
  groups: sudo
  shell: /bin/bash
  sudo: ['ALL=(ALL) NOPASSWD:ALL']
  ssh_authorized_keys:
    - ${var.cloud_init_pub_ssh_key}
  lock_passwd: false
  passwd: ${var.cloud_init_password}
ssh_pwauth: true
preserve_hostname: false
hostname: ${var.proxmox_vm_name}-proxy-${count.index + 1}
fqdn: ${var.proxmox_vm_name}-proxy-${count.index + 1}.${var.cloud_init_domain}
manage_etc_hosts: true
manage_resolv_conf: true
write_files:
  - path: /usr/local/bin/update-issue.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      echo "Welcome to $(lsb_release -d -s)" > /etc/issue
      echo "" >> /etc/issue
      for interface in $(ls /sys/class/net | grep -v lo); do
          IP=$(ip addr show $interface | grep 'inet ' | awk '{print $2}')
          echo "$interface: $IP" >> /etc/issue
      done
      echo "" >> /etc/issue
      systemctl restart getty@tty1.service
  - path: /etc/sysctl.d/99-disable-ipv6.conf
    permissions: '0644'
    owner: root:root
    content: |
      net.ipv6.conf.all.disable_ipv6 = 1
      net.ipv6.conf.default.disable_ipv6 = 1
      net.ipv6.conf.lo.disable_ipv6 = 1
  - path: /etc/sysctl.d/99-swappiness.conf
    permissions: '0644'
    owner: root:root
    content: |
      vm.swappiness=1
  - path: /usr/local/share/ca-certificates/adamkoro.local.crt
    content: |
      -----BEGIN CERTIFICATE-----
      MIIGeDCCBGCgAwIBAgIUXEAlSELTC9mz/+SfoOt/iE3tTcYwDQYJKoZIhvcNAQEL
      BQAwgakxCzAJBgNVBAYTAkhVMRAwDgYDVQQIDAdCYXJhbnlhMQ0wCwYDVQQHDARQ
      ZWNzMRYwFAYDVQQKDA1BZGFta29ybyBIb21lMRkwFwYDVQQLDBBBZGFta29ybyBI
      b21lIENBMR4wHAYDVQQDDBVBZGFta29ybyBIb21lIFJvb3QgQ0ExJjAkBgkqhkiG
      9w0BCQEWF2FkYW0ua29yb25pY3NAZ21haWwuY29tMB4XDTIzMDgyMDE3MTA1OVoX
      DTI4MDgxODE3MTA1OVowgb4xCzAJBgNVBAYTAkhVMRAwDgYDVQQIDAdCYXJhbnlh
      MQ0wCwYDVQQHDARQZWNzMRYwFAYDVQQKDA1BZGFta29ybyBIb21lMSYwJAYDVQQL
      DB1BZGFta29ybyBIb21lIEludGVybWVkaWF0ZSBDQTEmMCQGA1UEAwwdQWRhbWtv
      cm8gSG9tZSBJbnRlcm1lZGlhdGUgQ0ExJjAkBgkqhkiG9w0BCQEWF2FkYW0ua29y
      b25pY3NAZ21haWwuY29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
      sD8zRvyhNYlArJ/TMSQlIkR/YfDm9do5bvPlpj5/RqzOMNHwB9jQeOjCG0VH2aqN
      R+Axah1G+2cqyMckJD8+6fFKmTUjEyBM7TilmJ/M8hZ9FFk7SMAa4IQgil222VGo
      +X7u6jGCmeWPSJqwd2ngk+GzRlQ2cygYBAblb7ocFz26T92n/k1L/Bs9zvrMCJJc
      NNrZfMhG8vtPpMUB98zlr7jDfz6kmRPJTUk0q+rs+45OondKfOUq9DM+rf0tOgyo
      SCRn9Csi8QpKWX8PV6xe0+UUt36XRWOKTY2bxZmvmXjHCat0LvHUimhCXYE+uuSu
      E/3zmgZLyiTWnzIIl+XOY3hcngOjUN2jspNzUJGHZIBiys6O4TiNBnwBbgd2cccS
      oZ2w2E2HQp7WhmeySMAnmP84w7XizhXKDGFlSOudOaVFgPvgdDmjGYVXNDsir+5w
      QEQCAg5gTZ27UFnEUAJFdCfhxS1wXxp9eRPzzwn3n8Pjm9NxDhjY1XlZuvvmXw0d
      fFykWHdPUFoTRm5akB1ykOmzL46ZfFy5MgnvVjRsAHRLRm8gapdHCvWWUbn4OCiZ
      K4zemqzrzaIuRGBSfZZ9RtQGTc4InRMenX0LOO9cfqXWsQVBvYyaIOTbj0mJkOdU
      l3jxdVB8GWnOMJN/pvK2TJW+VHz5O0eGYH3bW2pqMssCAwEAAaOBgDB+MBsGA1Ud
      EQQUMBKCECouYWRhbWtvcm8ubG9jYWwwDgYDVR0PAQH/BAQDAgIEMA8GA1UdEwEB
      /wQFMAMBAf8wHQYDVR0OBBYEFLNkdhHRyFRoWA4AqKKOq/m5zluIMB8GA1UdIwQY
      MBaAFHWSUIqvNxmacubeXfDM9C3QNESHMA0GCSqGSIb3DQEBCwUAA4ICAQB7pA7r
      zDXpKHXY+zLYrz2fBoPwrjz0DaYjlthbf+m1H1ngopXPDS72mu+mvSTwf0XGI8xj
      eNZB858gWaZQBdhyMl8jFDzJlIx6Gol5FIW9rm5UoaGkVT8dgv3BpiW0L8QeRnjb
      45LdwjR22YYGg3M9KYpopzBiHvkhoZ3zvCAeQ8BFciL5wVYHuM2eh+t3sQRtxiZQ
      hQoCONj0ByrfA8PU77m5m6mltO82vSPaCDJw+GYh5z5JbUGnQMvBli1gyGoOxQPE
      19ljhB4xxJ3UsksrcVbQMpHqN/K2ny197SoGrr06ms7EPa3I5BDdll2xVN1ucmAY
      ltjm5xziJjhbtOSuGNo1xvSK2xOVlDpMfrAsX0DLLW+ktlWJjJ5qRb8h+Tu4jFWu
      vSPM8X8LV3y8Tvwl3AXIk3RhIXmyuqfh6cZ5IFbtxT2VGXvHXc9eIMwm8Ft+kh7A
      eSMShZkiVCeDHKnAsqKu5c4WHlHWm7l1rDydr6jmNFaYP4EVNWz6XSnJ4ByKXX0v
      mHZBXU4IV5SmHkQDPDx27DTrhJ9Wfml8ZfOz9oGLWpF8FSI+i5JbTkyu1c+2xN6Z
      WZfm2rHRGf87Y+qG5K/QPT1dCqNRtNCb67+U/qZZF83j+Gr0p5HMseuq5N8q5V93
      jJWp7PpOvPUJHt4rqutKQL0fnhrnMTnESpuyJw==
      -----END CERTIFICATE-----
packages:
  - qemu-guest-agent
runcmd:
  - /usr/local/bin/update-issue.sh
  - sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
  - systemctl restart systemd-resolved
  - systemctl daemon-reload
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - update-ca-certificates
  - sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
  - sysctl -p /etc/sysctl.d/99-swappiness.conf
  EOT

  network_config = <<EOT
network:
  version: 2
  ethernets:
    enp6s18:
      dhcp4: no
      dhcp6: no
      addresses:
        - ${var.cloud_init_ip_pool0}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask}
      nameservers:
        addresses: [192.168.2.10, 192.168.2.5]
        search: [adamkoro.local, adamkoro.com]
      routes:
        - to: 0.0.0.0/0
          via: ${var.cloud_init_gateway0}
          metric: 50
    enp6s19:
      dhcp4: no
      dhcp6: no
      addresses:
        - ${var.cloud_init_ip_pool1}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask}
      nameservers:
        addresses: [${var.cloud_init_gateway1}]
      routes:
        - to: 0.0.0.0/0
          via: ${var.cloud_init_gateway1}
          metric: 100
    enp6s20:
      dhcp4: no
      dhcp6: no
      addresses:
        - ${var.cloud_init_ip_pool2}${count.index + var.cloud_init_ip_increase}/${var.cloud_init_netmask}
      routes:
        - to: 0.0.0.0/0
          via: ${var.cloud_init_gateway2}
          metric: 150
EOT
}
