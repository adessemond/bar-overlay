# Copyright 1999-2011 Gentoo Foundation
# Copyright 2011 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2


# XXX: the tarball here is just the kernel modules split out of the binary
#      package that comes from virtualbox-bin

EAPI=2

inherit eutils linux-mod

MY_P=vbox-kernel-module-src-${PV}
DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://dev.gentoo.org/~polynomial-c/virtualbox/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!=app-emulation/virtualbox-9999"

S=${WORKDIR}

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxdrv(misc:${S}) vboxnetflt(misc:${S}) vboxnetadp(misc:${S}) vboxpci(misc:${S})"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
	enewgroup vboxusers
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-vboxbug9305.patch

	if kernel_is -ge 2 6 33 ; then
		# evil patch for new kernels - header moved
		grep -lR linux/autoconf.h *  | xargs sed -i -e 's:<linux/autoconf.h>:<generated/autoconf.h>:'
	fi

	# Linux 3.1 series has moved a header file...

	if kernel_is -ge 3 1 0 ; then
		epatch "${FILESDIR}"/${P}-vboxpci-amd_iommu-h-linux-3.1.patch
	fi

}

src_install() {
	linux-mod_src_install
}

pkg_postinst() {
	linux-mod_pkg_postinst
	elog "Starting with the 3.x release new kernel modules were added,"
	elog "be sure to load all the needed modules."
	elog ""
	elog "Please add \"vboxdrv\", \"vboxnetflt\" and \"vboxnetadp\" to:"
	if has_version sys-apps/openrc; then
		elog "/etc/conf.d/modules"
	else
		elog "/etc/modules.autoload.d/kernel-${KV_MAJOR}.${KV_MINOR}"
	fi
}
