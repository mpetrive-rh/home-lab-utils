resource "libvirt_network" "towernet" {
  name = "towernet"
  mode = "nat"
  domain = "tower.local"
  addresses = [ "10.10.27.0/24" ]
  autostart = true

  dns {
    enabled = true
    local_only = false
  }
}