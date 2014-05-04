# Copyright 1999-2012 Gentoo Foundation
# Copyright 2014 Adrien Dessemond <adessemond@funtoo.org>
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib

DESCRIPTION="Text User Interface that implements the well known CUA widgets"
HOMEPAGE="http://tvision.sourceforge.net/"
SRC_URI="http://sourceforge.net/projects/tvision/files/UNIX/2.2.1%20CVS20100714%20Source%20and%20Debian%205.0/rhtvision_2.2.1-1.tar.gz" 

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~sparc"
IUSE=""

S=${WORKDIR}/${PN}

src_unpack() {

	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-missing-header.patch
	epatch "${FILESDIR}"/${P}-underflow.patch
	epatch "${FILESDIR}"/${P}-gcc44.patch
	epatch "${FILESDIR}"/${P}-ldconfig.patch
	epatch "${FILESDIR}"/${P}-flags.patch
}

src_compile() {
	./configure \
		--prefix=/usr \
		--fhs \
		|| die
	emake || die
}

src_install() {
	einstall libdir="\$(prefix)/$(get_libdir)"|| die
	dosym rhtvision /usr/include/tvision
	dodoc readme.txt THANKS TODO
	dohtml -r www-site
}
