# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Limine is a modern, advanced, and portable BIOS/UEFI multiprotocol bootloader"
HOMEPAGE="https://limine-bootloader.org/"
SRC_URI="https://github.com/limine-bootloader/limine/releases/download/v${PV}/limine-${PV}.tar.xz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="abi_x86_32 abi_x86_64 bios bios-pxe bios-cd uefi uefi-cd"

BDEPEND="
	app-alternatives/gzip
	dev-lang/nasm
	sys-apps/findutils
	uefi-cd? ( sys-fs/mtools )
"

REQUIRED_USE="
	bios? ( || ( amd64 x86 ) )
	bios-cd? ( || ( amd64 x86 ) )
	bios-pxe? ( || ( amd64 x86 ) )
"

src_configure() {
	local myconf=(
		$(use_enable bios)
		$(use_enable bios-cd)
		$(use_enable bios-pxe)

		$(use_enable uefi-cd)
	)

	if use uefi; then
		myconf+=(
			$(use_enable abi_x86_32 uefi-ia32)
			$(use_enable abi_x86_64 uefi-x86-64)
			$(use_enable arm64 uefi-aarch64)
			$(use_enable riscv uefi-riscv64)
		)
	fi

	econf "${myconf[@]}"
}
