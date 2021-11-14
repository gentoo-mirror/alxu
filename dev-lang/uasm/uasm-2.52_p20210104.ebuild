# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

COMMIT=c612f83d97a0cb192dfd983676743dabf662ed51

DESCRIPTION="free MASM-compatible assembler based on JWasm"
HOMEPAGE="http://www.terraspace.co.uk/uasm.html"
SRC_URI="https://github.com/Terraspace/UASM/archive/${COMMIT}.tar.gz -> uasm-${COMMIT:0:10}.tar.gz"

LICENSE="Watcom-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

S=${WORKDIR}/UASM-${COMMIT}

PATCHES=(
	"${FILESDIR}/dbgcv.patch"
	"${FILESDIR}/151.patch"
)

src_compile() {
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} \
		-D__UNIX__ -IH $(usex debug -DDEBUG_OUT -DNDEBUG) -fcommon \
		main.c $(sed -n -e '/\.o/{s#\$(OUTD)/##;s#\.o.*$#.c#;p}' gccmod.inc) \
		-o uasm || die
}

src_install() {
	dobin uasm
}
