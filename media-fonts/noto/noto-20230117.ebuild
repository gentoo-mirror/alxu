# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google's font family that aims to support all the world's languages"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-fonts"

COMMIT="6bff404f9a23cd603190277422d043a0afd7908e"
SRC_URI="
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSans/googlefonts/variable-ttf/NotoSans%5Bwdth%2Cwght%5D.ttf -> NotoSans[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSans/googlefonts/variable-ttf/NotoSans-Italic%5Bwdth%2Cwght%5D.ttf -> NotoSans-Italic[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSerif/googlefonts/variable-ttf/NotoSerif%5Bwdth%2Cwght%5D.ttf -> NotoSerif[wdth,wght]-${COMMIT}.ttf
	https://github.com/notofonts/notofonts.github.io/raw/${COMMIT}/fonts/NotoSerif/googlefonts/variable-ttf/NotoSerif-Italic%5Bwdth%2Cwght%5D.ttf -> NotoSerif-Italic[wdth,wght]-${COMMIT}.ttf
	"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

S="${DISTDIR}"

src_install() {
	insinto /usr/share/fonts/${PN}
	newins "NotoSans[wdth,wght]-${COMMIT}.ttf" "NotoSans[wdth,wght].ttf"
	newins "NotoSans-Italic[wdth,wght]-${COMMIT}.ttf" "NotoSans-Italic[wdth,wght].ttf"
	newins "NotoSerif[wdth,wght]-${COMMIT}.ttf" "NotoSerif[wdth,wght].ttf"
	newins "NotoSerif-Italic[wdth,wght]-${COMMIT}.ttf" "NotoSerif-Italic[wdth,wght].ttf"
	insinto /etc/fonts/conf.avail
	# From ArchLinux
	doins "${FILESDIR}/66-noto-serif.conf"
	doins "${FILESDIR}/66-noto-mono.conf"
	doins "${FILESDIR}/66-noto-sans.conf"
}
