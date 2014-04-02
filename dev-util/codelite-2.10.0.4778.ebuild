# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

WX_GTK_VER="2.8"

inherit eutils wxwidgets

DESCRIPTION="A Cross Platform Open Source C/C++ IDE"
HOMEPAGE="http://www.codelite.org/"
SRC_URI="http://surfnet.dl.sourceforge.net/project/codelite/Releases/codelite-2.10/codelite-${PV}.tar.gz http://softlayer.dl.sourceforge.net/project/codelite/Releases/codelite-2.10/codelite-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="subversion"

RDEPEND=""

DEPEND="${RDEPEND}
	x11-libs/wxGTK:2.8[X]
	net-misc/curl
	>=sys-devel/gdb-7.1
	subversion? ( dev-vcs/subversion )"

src_configure() {
	./configure --prefix=/usr || die "configure failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "install failed"
}

