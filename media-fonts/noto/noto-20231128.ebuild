# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit font

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://fonts.google.com/noto https://github.com/notofonts/notofonts.github.io"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

COMMIT="15866b860084edd7163ec170d3c462ceada3de5b"
SRC_URI="
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSans/googlefonts/variable-ttf/NotoSans%5Bwdth%2Cwght%5D.ttf -> NotoSans[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSans/googlefonts/variable-ttf/NotoSans-Italic%5Bwdth%2Cwght%5D.ttf -> NotoSans-Italic[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSerif/googlefonts/variable-ttf/NotoSerif%5Bwdth%2Cwght%5D.ttf -> NotoSerif[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSerif/googlefonts/variable-ttf/NotoSerif-Italic%5Bwdth%2Cwght%5D.ttf -> NotoSerif-Italic[wdth,wght]-${COMMIT}.ttf
	"

S="${WORKDIR}"

FONT_SUFFIX="ttf"
FONT_CONF=(
    # From ArchLinux
    "${FILESDIR}/66-noto-serif.conf"
    "${FILESDIR}/66-noto-mono.conf"
    "${FILESDIR}/66-noto-sans.conf"
)

src_compile() {
	for f in "${DISTDIR}"/*.ttf; do
		fn=${f##*/}
		cp "$f" "${fn/-$COMMIT}"
	done
}
