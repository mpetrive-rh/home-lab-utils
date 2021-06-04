resource "libvirt_pool" "linux_pool" {
  name = "linux_pool"
  type = "dir"
  path = var.libvirt_pool_location
}

resource "libvirt_volume" "rhel-volume" {
  count = var.rhel_count 
  name   = "rhel_qcow2_${count.index}"
  pool   = libvirt_pool.linux_pool.name
  source = var.rhel_qcow_image
  format = "qcow2"
}