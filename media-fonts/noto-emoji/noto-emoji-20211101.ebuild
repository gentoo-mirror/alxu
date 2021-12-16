# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google Noto Emoji fonts"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-emoji"

COMMIT="9a5261d871451f9b5183c93483cbd68ed916b1e9"
SRC_URI="
	https://github.com/googlefonts/noto-emoji/raw/${COMMIT}/fonts/NotoColorEmoji.ttf -> NotoColorEmoji-${COMMIT}.ttf
	https://github.com/googlefonts/noto-emoji/raw/${COMMIT}/fonts/NotoEmoji-Regular.ttf -> NotoEmoji-Regular-${COMMIT}.ttf
"

LICENSE="Apache-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

S="${DISTDIR}"

src_install() {
	insinto /usr/share/fonts/${PN}
	newins NotoColorEmoji-${COMMIT}.ttf NotoColorEmoji.ttf
	newins NotoEmoji-Regular-${COMMIT}.ttf NotoEmoji-Regular.ttf
}
