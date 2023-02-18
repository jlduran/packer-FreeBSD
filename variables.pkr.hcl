variable "arch" {
  type    = string
  default = "amd64"
}

variable "branch" {
  type    = string
  default = "-RELEASE"
}

variable "build_date" {
  type    = string
  default = ""
}

variable "cpus" {
  type    = number
  default = 1
}

variable "directory" {
  type    = string
  default = "releases"
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
  default = ""
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
  default = "13.1"
}
