# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION='"minimum viable product" Wayland compositor based on wlroots'
HOMEPAGE="https://gitlab.freedesktop.org/wlroots/wlroots/-/tree/tinywl"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/wlroots/wlroots.git"
	inherit git-r3
else
	SRC_URI="https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/${PV}/wlroots-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="CC0-1.0"
SLOT="0"
IUSE=""

DEPEND="
	>=gui-libs/wlroots-${PV}:=
	dev-libs/wayland-protocols
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	dev-libs/wayland-protocols
	virtual/pkgconfig
"

S=${WORKDIR}/wlroots-${PV}

PATCHES=(
	"${FILESDIR}/tinywl-don-t-crash-when-there-is-no-keyboard.patch"
)

S="${WORKDIR}/wlroots-${PV}/tinywl"

src_prepare() {
	cd ..
	default
}

src_install() {
	dobin tinywl
}
