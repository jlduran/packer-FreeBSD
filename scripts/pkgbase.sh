#!/bin/sh
set -e

BASE_REPOS_DIR="/usr/local/etc/pkg/repos"

# Set the time
service ntpdate onestart || true

# Bootstrap pkg
env ASSUME_ALWAYS_YES=yes pkg bootstrap -f

# Upgrade packages
pkg upgrade -qy

# Create a directory for repository configuration files,
# then add a FreeBSD-base.conf file
mkdir -p "$BASE_REPOS_DIR"
cat <<'EOF' > "${BASE_REPOS_DIR}/FreeBSD-base.conf"
FreeBSD-base: {
  url: "pkg+https://pkg.FreeBSD.org/${ABI}/base_release_1",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF

# Update repositories
pkg update

# Install base packages from the FreeBSD-base repo
pkg -o REPOS_DIR="$BASE_REPOS_DIR" search -qCx '^FreeBSD-.*' | \
	grep -vE -- '-dbg|-dev-|-games-|-lib32|-mmccam-|-minimal-|-src-|-tests' | \
	xargs env HANDLE_RC_SCRIPTS=yes pkg -o REPOS_DIR="$BASE_REPOS_DIR" install -y

# Error if there is a .pkgsave file
find / -name "*.pkgsave" -type f -exec sh -c exit 1 \;

# Remove freebsd-update
rm -rf /var/db/freebsd-update
rm -f /usr/sbin/freebsd-update

# Upgrade boot partition
fetch -o /tmp https://raw.githubusercontent.com/freebsd/freebsd-src/main/tools/boot/install-boot.sh
GEOM=""
if [ -e /dev/ada0 ]; then
	GEOM=ada0 # ATA (VirtualBox)
fi
if [ -e /dev/da0 ]; then
	GEOM=da0 # SCSI (VMWare)
fi
if [ -e /dev/vtbd0 ]; then
	GEOM=vtbd0 # VirtIO (QEMU)
fi

if [ -n "$GEOM" ]; then
	sh /tmp/install-boot.sh -b legacy -f "$(cat /tmp/fstyp)" -s gpt "$GEOM"
fi

# XXX Change root's password to vagrant (again)
# pkgbase overwrites master.passwd
echo 'vagrant' | pw usermod root -h 0
