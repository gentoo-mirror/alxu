# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The DWARF Debugging Information Format"
HOMEPAGE="https://github.com/davea42/libdwarf-code"
SRC_URI="https://github.com/davea42/libdwarf-code/releases/download/v${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dwarfexample dwarfgen static-libs"

DEPEND="
	sys-libs/zlib
	dwarfgen? ( virtual/libelf )
"
RDEPEND="${DEPEND}"

src_configure() {
	local myeconfargs=(
		--includedir="${EPREFIX}/usr/include/${PN}"
		--enable-shared
		$(use_enable dwarfexample)
		$(use_enable dwarfgen)
		$(use_enable dwarfgen libelf)
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
