# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Start an xorg server"
HOMEPAGE="https://github.com/Earnestly/sx"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Earnestly/sx.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/Earnestly/sx/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"

src_compile() {
	:
}

src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install
}
