# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google Noto Emoji fonts"
HOMEPAGE="https://fonts.google.com/noto/specimen/Noto+Emoji"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

PROPERTIES="live"

BDEPEND="
	app-arch/unzip
	|| (
		net-misc/curl
		net-misc/wget
	)
"

S="${WORKDIR}"

get() {
	if hash curl 2>/dev/null; then
		curl -Lf --retry 3 --connect-timeout 60 --speed-limit 300 --speed-time 10 "$@"
	elif hash wget 2>/dev/null; then
		wget -O- "$@"
	else
		die
	fi
}

src_unpack() {
	get https://fonts.google.com/download?family=Noto%20Emoji > Noto_Emoji.zip || die
	unzip Noto_Emoji.zip || die
}

src_install() {
	insinto /usr/share/fonts/${PN}
	doins NotoEmoji-VariableFont_wght.ttf
}
