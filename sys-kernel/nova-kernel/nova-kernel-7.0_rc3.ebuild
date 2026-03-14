# Copyright 2026
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
DEPEND="sys-devel/bc
        sys-devel/flex
        sys-devel/bison
        dev-libs/openssl:=
        sys-libs/zlib"
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
