# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Start an xorg server"
HOMEPAGE="https://github.com/Earnestly/sx"
EGIT_REPO_URI="https://github.com/Earnestly/sx.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

src_compile() {
	:
}

src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install
}
