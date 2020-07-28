# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 meson

DESCRIPTION="Displays keys being pressed on a Wayland session"
HOMEPAGE="https://git.sr.ht/~sircmpwn/wshowkeys"
EGIT_REPO_URI="https://git.sr.ht/~sircmpwn/wshowkeys"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/libinput
	dev-libs/wayland
	virtual/libudev
	x11-libs/cairo
	x11-libs/libxkbcommon
	x11-libs/pango
"
DEPEND="${RDEPEND}
	dev-libs/wayland-protocols
"

src_install() {
	meson_src_install
	fperms u+s /usr/bin/wshowkeys
}
