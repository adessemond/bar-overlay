# Copyright 1999-2011 Gentoo Foundation
# Copyright 2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2

inherit linux-mod eutils flag-o-matic

DESCRIPTION="Open Source iSCSI target with professional features"
HOMEPAGE="http://iscsitarget.sourceforge.net/"
My_P="${P%_*}"
SRC_URI="mirror://sourceforge/${PN}/${My_P}.tar.gz"
S="${WORKDIR}/${My_P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86 "
IUSE=""

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"

MODULE_NAMES="iscsi_trgt(misc:${S}/kernel)"
CONFIG_CHECK="CRYPTO_CRC32C"
ERROR_CFG="iscsitarget needs support for CRC32C in your kernel."

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Patch to trunk revision #483 (2012-04-27)
	epatch "${FILESDIR}/${PN}-svn-r481.patch"

	# Even at trunk revision 483, patch for bug #180619 is still valid
	epatch "${FILESDIR}"/${PN}-0.4.15-isns-set-scn-flag.patch #180619
	
	# Gentoo bugs #340449, #350742 are solved in recent commit 
	# No more problems with LDFLAGS no patch required :-)

	#convert_to_m "${S}"/Makefile
}

src_compile() {
	emake KSRC="${KERNEL_DIR}" usr || die

	unset ARCH
	emake KSRC="${KERNEL_DIR}" kernel || die
}

src_install() {
	einfo "Installing userspace"

	# Install ietd into libexec; we don't need ietd to be in the path
	# for ROOT, since it's just a service.
	exeinto /usr/libexec
	doexe usr/ietd || die

	dosbin usr/ietadm || die

	insinto /etc
	doins etc/ietd.conf etc/initiators.allow || die

	# We moved ietd in /usr/libexec, so update the init script accordingly.
	sed -e 's:/usr/sbin/ietd:/usr/libexec/ietd:' "${FILESDIR}"/ietd-init.d-2 > "${T}"/ietd-init.d
	newinitd "${T}"/ietd-init.d ietd || die
	newconfd "${FILESDIR}"/ietd-conf.d ietd || die

	# Lock down perms, per bug 198209
	fperms 0640 /etc/ietd.conf /etc/initiators.allow

	doman doc/manpages/*.[1-9] || die
	dodoc ChangeLog README RELEASE_NOTES README.initiators README.vmware || die

	einfo "Installing kernel module"
	unset ARCH
	linux-mod_src_install || die
}
