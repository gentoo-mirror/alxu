# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit meson

SRC_URI="https://github.com/emersion/${PN}/releases/download/v${PV}/${P}.tar.gz"
DESCRIPTION="xdg-desktop-portal backend for wlroots"
HOMEPAGE="https://github.com/emersion/xdg-desktop-portal-wlr"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd elogind"

# FIXME: The X and wayland options are autodetected.
BDEPEND="
	virtual/pkgconfig
	>=sys-devel/gettext-0.18.3
"
DEPEND="
	>=media-video/pipewire-0.3
	dev-libs/wayland
	>=dev-libs/wayland-protocols-1.14
	>=sys-apps/xdg-desktop-portal-1.7.0
	systemd? ( sys-apps/systemd )
	elogind? ( sys-auth/elogind )
"
RDEPEND="${DEPEND}"
REQUIRED_USE="
	?? ( systemd elogind )
"

src_configure() {
	local emesonargs=(
		$(meson_feature systemd)
	)
	meson_src_configure
}
