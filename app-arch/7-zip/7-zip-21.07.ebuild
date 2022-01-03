# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

MY_PV=${PV%%_*}
MY_PV=${MY_PV//./}

DESCRIPTION="File archiver with a high compression ratio"
HOMEPAGE="https://7-zip.org/"
SRC_URI="https://7-zip.org/a/7z${MY_PV}-src.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+asm"

BDEPEND="
	asm? ( dev-lang/jwasm )
"
RDEPEND="!app-arch/p7zip"

S=${WORKDIR}

PATCHES=( ${FILESDIR}/7-zip-flags.patch )

src_compile() {
	cd CPP/7zip/Bundles/Alone2 || die
	local myemakeargs=(
		CC="$(tc-getCC) ${CFLAGS} ${LDFLAGS}"
		CXX="$(tc-getCXX) ${CXXFLAGS} ${LDFLAGS}"
	)
	if use asm; then
		myemakeargs+=(USE_ASM=1 USE_JWASM=1)
		if use amd64; then
			myemakeargs+=(IS_X64=1)
		elif use arm64; then
			myemakeargs+=(IS_ARM64=1)
		elif use x86; then
			myemakeargs+=(IS_X86=1)
		else
			einfo "asm is not supported on this arch, ignoring"
		fi
	fi
	mkdir -p b/g || die
	emake -f ../../cmpl_gcc.mak "${myemakeargs[@]}"
}

src_install() {
	dobin CPP/7zip/Bundles/Alone2/b/g/7zz
	dosym 7zz /usr/bin/7z
	dodoc DOC/*
}
