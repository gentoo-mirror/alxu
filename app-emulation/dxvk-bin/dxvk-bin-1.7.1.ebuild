# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Vulkan-based D3D11 and D3D10 implementation for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"
SRC_URI="https://github.com/doitsujin/dxvk/releases/download/v${PV}/dxvk-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
# x86 is fine except for the stupid vulkan package.use.mask...
KEYWORDS="-* ~amd64"
IUSE="+abi_x86_32 +abi_x86_64"

RDEPEND="
	!app-emulation/dxvk
	|| (
		app-emulation/wine-vanilla[abi_x86_32?,abi_x86_64?,vulkan]
		app-emulation/wine-staging[abi_x86_32?,abi_x86_64?,vulkan]
	)
"

REQUIRED_USE="|| ( abi_x86_32 abi_x86_64 )"

S=${WORKDIR}/dxvk-${PV}

src_compile() {
	sed -i -e 's#"x32"#"../'$(ABI=x86 get_libdir)/dxvk'"#' setup_dxvk.sh || die
	sed -i -e 's#"x64"#"../'$(ABI=amd64 get_libdir)/dxvk'"#' setup_dxvk.sh || die
}

src_install() {
	dobin setup_dxvk.sh
	dodir usr/$(ABI=x86 get_libdir)
	dodir usr/$(ABI=amd64 get_libdir)
	mv x32 "${ED}"/usr/$(ABI=x86 get_libdir)/dxvk || die
	mv x64 "${ED}"/usr/$(ABI=amd64 get_libdir)/dxvk || die
}
