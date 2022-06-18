# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Launcher for official RuneScape NXT client launcher"
HOMEPAGE="https://cgit.alxu.ca/runescape-launcher-launcher.git/"
SRC_URI="https://www.alxu.ca/${P}.tar.xz"

LICENSE="0BSD RuneScape-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	sys-libs/libcap
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXxf86vm
	dev-libs/openssl-compat:1.1
	x11-libs/pango
	media-libs/libsdl2
"

src_compile() {
	emake prefix="${EPREFIX}/usr"
}

src_install() {
	emake prefix="${EPREFIX}/usr" DESTDIR=${D} install
}
