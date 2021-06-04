# install libvirt provider

yum install https://download.opensuse.org/repositories/systemsmanagement:/terraform/Fedora_32/x86_64/terraform-provider-libvirt-0.6.3+git.1604843676.67f4f2aa-13.1.x86_64.rpm 

cp -r /usr/share/terraform/plugins/registry.terraform.io ~/.terraform.d/plugins
cp /usr/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.3/linux_amd64/terraform-provider-libvirt ~/.terraform.d/plugins