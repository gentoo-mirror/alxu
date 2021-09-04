# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="OpenPGP keys used by Jagex to sign RuneScape packages for Ubuntu"
HOMEPAGE="https://www.runescape.com/"
SRC_URI="https://content.runescape.com/downloads/ubuntu/runescape.gpg.key"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~*"

S=${WORKDIR}

src_install() {
	local files=( ${A} )
	insinto /usr/share/openpgp-keys
	doins ${DISTDIR}/runescape.gpg.key
}
