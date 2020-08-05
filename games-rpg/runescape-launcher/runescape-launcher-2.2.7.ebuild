# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker

DESCRIPTION="Official RuneScape NXT client launcher"
HOMEPAGE="http://www.runescape.com"
SRC_URI="https://content.runescape.com/downloads/ubuntu/pool/non-free/${PN:0:1}/${PN}/${PN}_${PV}_amd64.deb"

LICENSE="RuneScape-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"

DEPEND=""
RDEPEND="
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	sys-libs/libcap
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXxf86vm
	dev-libs/openssl
	x11-libs/pango
	media-libs/libsdl2"
BDEPEND=""

RESTRICT="bindist mirror strip"
QA_PREBUILT="/usr/share/games/runescape-launcher/runescape"

S="${WORKDIR}"

src_install() {
	cp -r usr "${D}"
}
