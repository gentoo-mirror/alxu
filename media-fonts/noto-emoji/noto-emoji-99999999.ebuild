# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google Noto Emoji fonts"
HOMEPAGE="https://fonts.google.com/noto/specimen/Noto+Emoji"

SRC_URI="https://fonts.google.com/download?family=Noto%20Emoji -> Noto_Emoji.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

BDEPEND="
	app-arch/unzip
"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/fonts/${PN}
	doins NotoEmoji-VariableFont_wght.ttf
}
