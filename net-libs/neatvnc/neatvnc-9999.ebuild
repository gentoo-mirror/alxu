# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A liberally licensed VNC server library with a clean interface"
HOMEPAGE="https://github.com/any1/neatvnc"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/any1/neatvnc.git"
else
	SRC_URI="https://github.com/any1/neatvnc/archive/v${PV}.tar.gz"
fi

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE="examples +jpeg ssl"

DEPEND="
	jpeg? ( media-libs/libjpeg-turbo )
	ssl? ( net-libs/gnutls:= )
	dev-libs/aml
	sys-libs/zlib
	x11-libs/pixman
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	sed -i -e '/x86_64-simd/s/^/#/' meson.build || die
}

src_configure() {
	local emesonargs=(
		$(meson_use examples)
		$(meson_feature jpeg tight-encoding)
		$(meson_feature ssl tls)
	)

	meson_src_configure
}
