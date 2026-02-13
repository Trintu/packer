variable "ssh_password" {
  type    = string
  default = ""
  sensitive = true
}

variable "switch_name" {
  type    = string
  default = ""
}

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "http_directory" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable  "provision_file" {
  type    = string
  default = ""
}

variable  "neofetch_file" {
  type    = string
  default = ""
}


source "hyperv-iso" "vm" {
  boot_command          = [

    "<esc><esc><enter><wait>",
    "/install/vmlinuz noapic ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
    "hostname={{ .Name }} ",
    "fb=false debconf/frontend=noninteractive ",
    "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
    "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
    "initrd=/install/initrd.gz -- <enter>"

]
  boot_wait             = "10s"
  communicator          = "ssh"
  cpus                  = "2"
  disk_block_size       = "1"
  disk_size             = "40000"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  http_directory        = "${var.http_directory}"
  iso_checksum          = "sha256:dc54870e5261c0abad19f74b8146659d10e625971792bd42d7ecde820b60a1d0"
  iso_url               = "https://www.releases.ubuntu.com/25.10/ubuntu-25.10-live-server-amd64.iso"
  memory                = "4096"
  output_directory      = "output-ubuntu2510"
  shutdown_command      = "echo 'password' | sudo -S shutdown -P now"
  shutdown_timeout      = "30m"
  ssh_password          = "${var.ssh_password}"
  ssh_timeout           = "4h"
  ssh_username          = "${var.ssh_username}"
  switch_name           = "${var.switch_name}"
  temp_path             = "."
  vm_name               = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.vm"]

  provisioner "file" {
    destination = "/tmp/provision.sh"
    source      = "${var.provision_file}"
  }

  provisioner "shell" {
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    expect_disconnect = true
    inline            = ["chmod +x /tmp/provision.sh", "/tmp/provision.sh -z false -h true -p false", "sync;sync;reboot"]
    inline_shebang    = "/bin/sh -x"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["echo Last Phase",
    "/bin/rm -rfv /tmp/*",
    "/bin/rm -f /etc/ssh/*key*",
    "/usr/bin/ssh-keygen -A",
    "echo 'packerVersion: ${packer.version}' >>/etc/packerinfo"]
    inline_shebang  = "/bin/sh -x"
  }

}