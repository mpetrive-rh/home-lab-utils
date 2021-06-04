
data "template_file" "user_data" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    key_file = file(var.ssh_key)
  }
}
resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.rhel_count
  name           = "commoninit${count.index}.iso"
  user_data      = data.template_file.user_data.rendered
  # network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.linux_pool.name
}

resource "libvirt_domain" "domain-linux" {
  count = var.rhel_count
  name   = "linux-terraform${count.index}"
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  network_interface {
    network_name = "towernet"
    hostname = "tower${count.index}"
  }

  network_interface {

    # NOTE: if this interface doesn't come up check the following
    # 1 - NetworkManager on KVM /libvirt host
    # 2 - Status of firewalld on KVM/libvirt host.  may need restart or stop depending on config
    # 3 - NetworkManager on guest.  may need to bring ifs up/doww
    
    bridge = "br0"

    # future/optional params
    # wait_for_lease = true
    # hostname = "tower${count.index}"
    # network_name = "br0"
    addresses = [ "192.168.1.${200+count.index}" ]
  }
  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.rhel-volume[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ipv4address" {
  value = flatten(libvirt_domain.domain-linux[*].network_interface[0].addresses)
}

output "ipv4address_bridge" {
  value = flatten(libvirt_domain.domain-linux[*].network_interface[1].addresses)
}

# output "kv" {
#   value=var.ssh_key
# }

# output "fv" {
#   value=data.template_file.user_data.rendered
# }