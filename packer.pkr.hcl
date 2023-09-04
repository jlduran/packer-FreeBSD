source "qemu" "freebsd" {
  boot_command            = ["<esc><wait>", "boot -s<enter>", "<wait15s>", "/bin/sh<enter><wait>", "mdmfs -s 100m md /tmp<enter><wait>", "dhclient -l /tmp/dhclient.lease.vtnet0 vtnet0<enter><wait5>", "fetch -o /tmp/installerconfig http://{{ .HTTPIP }}:{{ .HTTPPort }}/installerconfig<enter><wait5>", "FILESYSTEM=${var.filesystem}<enter>", "export FILESYSTEM<enter>", "ZFS_COMPRESSION=${var.zfs_compression}<enter>", "export ZFS_COMPRESSION<enter>", "RC_CONF_FILE=${var.rc_conf_file}<enter>", "export RC_CONF_FILE<enter>", "bsdinstall script /tmp/installerconfig<enter>"]
  boot_wait               = "5s"
  cpus                    = "${var.cpus}"
  disk_size               = "${var.disk_size}"
  headless                = true
  http_directory          = "http"
  iso_checksum            = "file:${var.mirror}/${var.directory}/ISO-IMAGES/${var.revision}/CHECKSUM.SHA256-FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}"
  iso_urls                = ["iso/FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}-disc1.iso", "${var.mirror}/${var.directory}/ISO-IMAGES/${var.revision}/FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}-disc1.iso"]
  memory                  = "${var.memory}"
  shutdown_command        = "poweroff"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "1000s"
  ssh_username            = "root"
  vm_name                 = "box"
}

source "virtualbox-iso" "freebsd" {
  boot_command            = ["<esc><wait>", "boot -s<enter>", "<wait15s>", "/bin/sh<enter><wait>", "mdmfs -s 100m md /tmp<enter><wait>", "dhclient -l /tmp/dhclient.lease.vtnet0 vtnet0<enter><wait5>", "fetch -o /tmp/installerconfig http://{{ .HTTPIP }}:{{ .HTTPPort }}/installerconfig<enter><wait5>", "FILESYSTEM=${var.filesystem}<enter>", "export FILESYSTEM<enter>", "ZFS_COMPRESSION=${var.zfs_compression}<enter>", "export ZFS_COMPRESSION<enter>", "RC_CONF_FILE=${var.rc_conf_file}<enter>", "export RC_CONF_FILE<enter>", "bsdinstall script /tmp/installerconfig<enter>"]
  boot_wait               = "10s"
  cpus                    = "${var.cpus}"
  chipset                 = "ich9"
  disk_size               = "${var.disk_size}"
  export_opts             = ["--manifest", "--vsys", "0", "--product", "FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}", "--producturl", "https://www.freebsd.org", "--description", "FreeBSD is an operating system used to power modern servers, desktops, and embedded platforms.", "--version", "${var.revision}-${var.branch}"]
  firmware                = "efi"
  gfx_controller          = "vmsvga"
  gfx_vram_size           = 5
  guest_additions_mode    = "disable"
  guest_os_type           = "${var.guest_os_type}"
  hard_drive_interface    = "virtio"
  headless                = true
  http_directory          = "http"
  iso_checksum            = "file:${var.mirror}/${var.directory}/ISO-IMAGES/${var.revision}/CHECKSUM.SHA256-FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}"
  iso_interface           = "virtio"
  iso_urls                = ["iso/FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}-disc1.iso", "${var.mirror}/${var.directory}/ISO-IMAGES/${var.revision}/FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}-disc1.iso"]
  memory                  = "${var.memory}"
  nested_virt             = true
  nic_type                = "virtio"
  shutdown_command        = "poweroff"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "1000s"
  ssh_username            = "root"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--mouse", "usbmultitouch", "--pae", "off"], ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"]]
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "box"
}

build {
  sources = [
    "source.qemu.freebsd",
    "source.virtualbox-iso.freebsd"
  ]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}"
    scripts         = ["scripts/update.sh", "scripts/vagrant.sh", "scripts/zeroconf.sh", "scripts/ansible.sh", "scripts/cloud-init.sh", "scripts/vmtools.sh", "scripts/cleanup.sh"]
  }

  post-processor "vagrant" {
    output               = "builds/FreeBSD-${var.revision}-${var.branch}-${var.arch}${var.build_date}${var.git_commit}.box"
    vagrantfile_template = "vagrantfile.tpl"
  }
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}
