# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Linux 7.0-rc3 built from upstream sources with local config"
HOMEPAGE="https://git.kernel.org/ https://www.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

# Portage uses _rc, upstream tarball uses -rc
MY_PV="${PV/_rc/-rc}"
MY_P="linux-${MY_PV}"

SRC_URI="https://git.kernel.org/torvalds/t/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

# Optional but nice
DEPEND="app-alternatives/awk
        app-alternatives/bc
		app-alternatives/cpio
		app-alternatives/gpg
		app-alternatives/gzip
		app-alternatives/sh
		app-arch/bzip2
		app-arch/gzip
		app-arch/lz4
		app-arch/tar
		app-arch/xz-utils
		app-arch/zstd
		app-crypt/argon2
		app-crypt/gnupg
		app-crypt/p11-kit
		app-crypt/sbsigntools
		app-crypt/tpm2-tools
		app-crypt/tpm2-tss
		app-misc/ddcutil
		app-misc/jq
		app-shells/bash
		dev-lang/perl
		dev-lang/python
		dev-libs/glib
		dev-libs/expat
		dev-libs/libevent
		dev-libs/libgpg-error
		dev-libs/libgcrypt
		dev-libs/libusb
		dev-libs/lzo
		dev-libs/npth
		dev-libs/nss
		dev-libs/opensc
		dev-libs/openssl
		dev-libs/userspace-rcu
		net-fs/nfs-utils
		net-fs/cifs-utils
		net-fs/samba
		net-libs/nghttp2
		net-misc/curl
		net-misc/networkmanager
		net-wireless/bluez
		sec-keys/openpgp-keys-kernel
		sys-apps/coreutils
		sys-apps/dbus
		sys-apps/fwupd
		sys-apps/gawk
		sys-apps/iproute2
		sys-apps/keyutils
		sys-apps/kmod
		sys-apps/less
		sys-apps/nvme-cli
		sys-apps/pcsc-lite
		sys-apps/rng-tools
		sys-apps/sed
		sys-apps/shadow
		sys-apps/util-linux
		sys-auth/polkit
		sys-devel/gcc
		sys-fs/cryptsetup
		sys-fs/dosfstools
		sys-kernel/dracut
		sys-libs/glibc
		sys-libs/libapparmor
		sys-libs/libnvme
		sys-libs/pam
		sys-libs/ncurses
		sys-process/procps
		x11-libs/libdrm"
RDEPEND=""
BDEPEND="${DEPEND}"

KERNEL_ARCH="x86"

src_prepare() {
    default

    cp "${FILESDIR}/kernel.config" "${S}/.config" || die "failed to copy kernel config"
}

src_compile() {
    emake ARCH="${KERNEL_ARCH}" olddefconfig || die "olddefconfig failed"
    emake ARCH="${KERNEL_ARCH}" bzImage modules || die "kernel build failed"
}

src_install() {
	local kvrel

	kvrel="$(emake -s ARCH="${KERNEL_ARCH}" kernelrelease)" || die "failed to get kernel release"

	# Install modules into the image root
	emake ARCH="${KERNEL_ARCH}" INSTALL_MOD_PATH="${D}" modules_install || die "modules_install failed"

	# Install kernel + metadata into /boot
	insinto /boot
	newins "arch/${KERNEL_ARCH}/boot/bzImage" "vmlinuz-${kvrel}" || die "failed to install kernel image"
	newins "System.map" "System.map-${kvrel}" || die "failed to install System.map"
	newins ".config" "config-${kvrel}" || die "failed to install config"

	# Optional: keep a copy of the prepared sources
	dodir /usr/src || die
	cp -a "${S}" "${ED}/usr/src/linux-${kvrel}" || die "failed to install sources"
}

pkg_postinst() {
	elog "Kernel installed."
	elog "Check /boot for:"
	elog "  vmlinuz-*"
	elog "  System.map-*"
	elog "  config-*"
	elog
	elog "You may still need to update your bootloader."
}
