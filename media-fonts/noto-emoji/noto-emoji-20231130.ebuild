# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit font

DESCRIPTION="Google Noto Emoji fonts"
HOMEPAGE="https://fonts.google.com/noto/specimen/Noto+Emoji"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMIT="d79d23e6822e0f6e5731b114cbfb26b2a4e380da"
SRC_URI="https://github.com/googlefonts/noto-emoji/raw/${COMMIT}/fonts/Noto-COLRv1.ttf -> Noto-COLRv1-${COMMIT}.ttf"

S="${WORKDIR}"

FONT_SUFFIX="ttf"

src_compile() {
	for f in "${DISTDIR}"/*.ttf; do
		fn=${f##*/}
		cp "$f" "${fn/-$COMMIT}"
	done
}
