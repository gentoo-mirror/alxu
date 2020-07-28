# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A VNC server for wlroots based Wayland compositors"
HOMEPAGE="https://github.com/any1/wayvnc"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/any1/wayvnc.git"
else
	SRC_URI="https://github.com/any1/wayvnc/archive/v${PV}.tar.gz"
fi

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="examples"

DEPEND="
	dev-libs/aml
	dev-libs/wayland
	net-libs/neatvnc
	virtual/opengl
	x11-libs/libxkbcommon
	x11-libs/pixman
"
RDEPEND="${DEPEND}"
BDEPEND="dev-libs/wayland"
