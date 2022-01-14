# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="NCurses Disk Usage"
HOMEPAGE="https://dev.yorhel.nl/ncdu/"
SRC_URI="https://dev.yorhel.nl/download/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="~dev-lang/zig-0.9.0"

DEPEND="sys-libs/ncurses:=[unicode(+)]"

RDEPEND="${DEPEND}"

src_compile() {
	if [[ -z ${ZIG_FLAGS+x} && "$CFLAGS" != *-march=native* ]]; then
		die 'ZIG_FLAGS is unset! note that zig defaults to native cpu. set ZIG_FLAGS="" or ZIG_FLAGS="-mcpu baseline"'
	fi
	emake PREFIX=${EPREFIX}/usr
}

src_install() {
	emake PREFIX=${ED}/usr install
}
