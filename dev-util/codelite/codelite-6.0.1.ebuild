# Copyright 1999-2014 Gentoo Foundation
# Copyright 2015 Adrien Dessemond <adrien.dessemond@funtoo.org>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

WX_GTK_VER="3.0"

inherit cmake-utils eutils wxwidgets

DESCRIPTION="open-source, cross platform IDE for the C/C++ programming languages"
HOMEPAGE="http://www.codelite.org/"
#SRC_URI="mirror://sourceforge/codelite/Releases/${P}/${P}-gtk.src.tar.gz"
SRC_URI="https://github.com/eranif/codelite/archive/${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~mips ~ppc ~ppc64 ~sh ~sparc ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="clang cscope debug git mysql pch postgres sftp subversion"

RDEPEND="dev-lang/python:2.7
	x11-libs/wxGTK:3.0[X]
	dev-libs/libedit
	sys-libs/ncurses[tinfo]
	clang? ( sys-devel/clang )
	cscope? ( dev-util/cscope )
	git? ( dev-vcs/git )
        >=dev-db/sqlite-3.0
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql )
	subversion? ( dev-vcs/subversion )
	sftp? ( net-libs/libssh )"

DEPEND="${RDEPEND}
        >=dev-util/cmake-2.6.2"

src_prepare () {
	 # Postgresql support enablement seems to be missing from all original CMake files
        epatch "${FILESDIR}/000-5.x-6.x-postgresql-support.patch"
	epatch "${FILESDIR}/001-6.x-conditionals-fix.patch"

	sed -i -e 's,set( PLUGINS_DIR "${CL_PREFIX}/${CL_INSTALL_LIBDIR}/codelite"),set( PLUGINS_DIR "${CL_PREFIX}/libexec/codelite"),' "${S}/CMakeLists.txt"
	ln -snf /lib/libedit.so.0 "${S}"/sdk/lldb/unix/lib/x86_64/libedit.so
}

src_configure () {

        local mycmakeargs=(
                "-DPLUGINS_DIR=/usr/libexec/codelite" \
                "-DENABLE_LLDB=0"  \
		$( cmake-utils_use_with pch PCH ) \
		$( cmake-utils_use_enable clang CLANG ) \
		$( cmake-utils_use_enable sftp SFTP ) \
                $( cmake-utils_use_with mysql MYSQL )
                $( cmake-utils_use_with postgres POSTGRES ) 
        )

        use subversion || comment_add_subdirectory Subversion2
        use git || comment_add_subdirectory git
        use cscope || comment_add_subdirectory cscope
        use debug && CMAKE_BUILD_TYPE="Debug" || CMAKE_BUILD_TYPE="Release"

        cmake-utils_src_configure
}

src_install () {

	cmake-utils_src_install
	dosym /lib/libedit.so.0 /usr/libexec/codelite/libedit.so
	dodoc AUTHORS

	# reverting the makefiles 666 chmod for this file
	chmod 0644 "${D}"/usr/share/codelite/codelite-icons.zip
}
