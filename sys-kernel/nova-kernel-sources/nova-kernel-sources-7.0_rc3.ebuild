# Copyright 2026
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Upstream Linux 7.0-rc3 sources with local .config"
HOMEPAGE="https://www.kernel.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

# Portage version uses _rc, upstream tarball uses -rc
MY_PV="${PV/_rc/-rc}"
MY_P="linux-${MY_PV}"
SRC_URI="https://git.kernel.org/torvalds/t/${MY_P}.tar.gz"
# https://git.kernel.org/torvalds/t/linux-7.0-rc3.tar.gz
S="${WORKDIR}/${MY_P}"

src_unpack() {
    unpack "${A}"
}

src_install() {
    dodir /usr/src || die

    cp -a "${S}" "${ED}/usr/src/${MY_P}" || die "failed to install source tree"

    cp "${FILESDIR}/amd64.config" \
        "${ED}/usr/src/${MY_P}/.config" || die "failed to install .config"
}

pkg_postinst() {
    elog "Installed sources to /usr/src/${MY_P}"
    elog "Run:"
    elog "  eselect kernel set ${MY_P}"
    elog "  cd /usr/src/linux"
    elog "  make olddefconfig"
    elog "  make -j\$(nproc)"
    elog "  make modules_install"
    elog "  make install"
}
