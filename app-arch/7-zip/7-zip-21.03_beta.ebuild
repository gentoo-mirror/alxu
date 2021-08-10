# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

MY_PV=${PV%%_*}
MY_PV=${MY_PV//./}

DESCRIPTION="File archiver with a high compression ratio"
HOMEPAGE="https://7-zip.org/"
SRC_URI="https://7-zip.org/a/7z${MY_PV}-src.7z"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="|| ( virtual/7z app-arch/libarchive app-arch/unar )"

S=${WORKDIR}/7z${MY_PV}-src

src_unpack() {
	if command -v 7z >/dev/null 2>&1; then
		7z x ${DISTDIR}/7z${MY_PV}-src.7z -o$S || die
	elif command -v bsdtar >/dev/null 2>&1; then
		mkdir $S || die
		bsdtar -C $S -xf ${DISTDIR}/7z${MY_PV}-src.7z || die
	elif command -v unar >/dev/null 2>&1; then
		unar -d $S ${DISTDIR}/7z${MY_PV}-src.7z || die
	else
		die "no 7z unpacker found"
	fi
}

src_prepare() {
	default
	sed -i -e 's/-Werror//g' -e "s/-O2/$CFLAGS/" CPP/7zip/7zip_gcc.mak || die
}

src_compile() {
	cd CPP/7zip/Bundles/Alone2
	append-ldflags -Wl,-z,noexecstack
	make -f ../../cmpl_gcc.mak
}

src_install() {
	dobin CPP/7zip/Bundles/Alone2/b/g/7zz
	dosym 7zz /usr/bin/7z
	dodoc DOC/*
}
