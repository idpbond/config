packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    docker = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# ---------- Variables ----------

variable "debian_version" {
  type    = string
  default = "trixie"
}

variable "ssh_password" {
  type    = string
  default = "packer"
}

# ---------- QEMU sources (qcow2) ----------

source "qemu" "amd64" {
  iso_url          = "https://cloud.debian.org/images/cloud/${var.debian_version}/latest/debian-13-genericcloud-amd64.qcow2"
  iso_checksum     = "none"
  disk_image       = true
  disk_size        = "20G"
  format           = "qcow2"
  accelerator      = "kvm"
  machine_type     = "q35"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  headless         = true
  ssh_username     = "packer"
  ssh_password     = var.ssh_password
  ssh_timeout      = "15m"
  shutdown_command  = "sudo shutdown -P now"
  output_directory = "output-sandclip-amd64"
  vm_name          = "sandclip-amd64.qcow2"
  qemuargs = [
    ["-m", "4096"],
    ["-smp", "4"],
  ]
  cd_files = [
    "cloud-init/user-data",
    "cloud-init/meta-data",
  ]
  cd_label = "cidata"
}

source "qemu" "arm64" {
  iso_url          = "https://cloud.debian.org/images/cloud/${var.debian_version}/latest/debian-13-genericcloud-arm64.qcow2"
  iso_checksum     = "none"
  disk_image       = true
  disk_size        = "20G"
  format           = "qcow2"
  accelerator      = "tcg"
  machine_type     = "virt"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  headless         = true
  ssh_username     = "packer"
  ssh_password     = var.ssh_password
  ssh_timeout      = "60m"
  shutdown_command  = "sudo shutdown -P now"
  output_directory = "output-sandclip-arm64"
  vm_name          = "sandclip-arm64.qcow2"
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-m", "4096"],
    ["-smp", "4"],
    ["-cpu", "cortex-a57"],
    ["-bios", "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd"],
  ]
  cd_files = [
    "cloud-init/user-data",
    "cloud-init/meta-data",
  ]
  cd_label = "cidata"
}

# ---------- Docker sources (OCI) ----------

source "docker" "amd64" {
  image  = "amd64/debian:${var.debian_version}-slim"
  commit = true
  changes = [
    "USER human",
    "WORKDIR /home/human",
    "ENV LANG=C.UTF-8",
    "ENV LC_ALL=C.UTF-8",
    "ENV TERM=xterm-256color",
    "ENTRYPOINT [\"/bin/zsh\"]",
  ]
}

source "docker" "arm64" {
  image  = "arm64v8/debian:${var.debian_version}-slim"
  commit = true
  changes = [
    "USER human",
    "WORKDIR /home/human",
    "ENV LANG=C.UTF-8",
    "ENV LC_ALL=C.UTF-8",
    "ENV TERM=xterm-256color",
    "ENTRYPOINT [\"/bin/zsh\"]",
  ]
}

# ---------- Builds ----------

build {
  name = "qcow2"

  sources = [
    "source.qemu.amd64",
    "source.qemu.arm64",
  ]

  provisioner "file" {
    source      = "../setup-env.sh"
    destination = "/tmp/setup-env.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup-env.sh",
      "sudo NONINTERACTIVE=1 TARGET_USER=human /tmp/setup-env.sh",
    ]
  }

  # Clean up cloud-init and packer user for smaller image
  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --logs || true",
      "sudo userdel -r packer || true",
      "sudo rm -rf /tmp/* /var/tmp/*",
    ]
  }

  post-processor "compress" {
    output = "output-sandclip-{{.BuildName}}/sandclip-{{.BuildName}}.qcow2.gz"
    keep_input_artifact = true
  }
}

build {
  name = "docker"

  sources = [
    "source.docker.amd64",
    "source.docker.arm64",
  ]

  provisioner "file" {
    source      = "../setup-env.sh"
    destination = "/tmp/setup-env.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup-env.sh",
      "SKIP_DOCKER=1 SKIP_SNAP=1 NONINTERACTIVE=1 /tmp/setup-env.sh",
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "ghcr.io/idpbond/sandclip"
      tags       = ["latest"]
    }
  }
}
