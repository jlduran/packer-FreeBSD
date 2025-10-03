variable "arch" {
  type    = string
  default = "amd64"
}

variable "branch" {
  type    = string
  default = "ALPHA3"
}

variable "build_date" {
  type    = string
  default = "-20250921"
}

variable "cpus" {
  type    = number
  default = 1
}

variable "directory" {
  type    = string
  default = "snapshots"
}

variable "disk_size" {
  type    = number
  default = 10240
}

variable "filesystem" {
  type    = string
  default = "zfs"
}

variable "zfs_compression" {
  type    = string
  default = "zstd"
}

variable "git_commit" {
  type    = string
  default = "-26988773d1da-280233"
}

variable "guest_os_type" {
  type    = string
  default = "FreeBSD_64"
}

variable "memory" {
  type    = number
  default = 1024
}

variable "mirror" {
  type    = string
  default = "https://download.freebsd.org"
}

variable "rc_conf_file" {
  type    = string
  default = ""
}

variable "revision" {
  type    = string
  default = "15.0"
}
