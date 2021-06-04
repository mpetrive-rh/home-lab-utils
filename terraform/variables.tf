variable "rhel_qcow_image" {
  description = "RHEL qcow2 image"
  type        = string
  default     = "/mnt/archive/rhel-8.3-update-2-x86_64-kvm.qcow2"
}

variable "rhel_count" {
  description = "number of machines"
  type        = number
  default     = 1
}

variable "ssh_key" {
  description = "ssh key to use in cloud init"
  type        = string
  default     = "/home/mpetrive/.ssh/id_rsa.pub"
}

variable "libvirt_pool_location" {
  description = "pool location"
  type        = string
  default     = "/opt/libvirt/terraform-provider-libvirt-pool-linux"
}