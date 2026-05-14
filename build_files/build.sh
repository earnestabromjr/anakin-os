#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install tmux ripgrep fd-find fzf zoxide bat lsd virt-manager gcc rust cargo unzip libvirt-daemon-driver-nodedev libvirt-daemon-driver-qemu libvirt-daemon-driver-storage-core qemu-audio-spice qemu-char-spice emu-device-display-qxl qemu-device-display-virtio-gpu qemu-device-display-virtio-vga qemu-device-usb-redirect qemu-system-x86-core -y 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
