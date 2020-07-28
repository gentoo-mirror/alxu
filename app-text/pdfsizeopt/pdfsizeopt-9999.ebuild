# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
inherit git-r3 python-single-r1

DESCRIPTION="PDF file size optimizer"
HOMEPAGE="https://github.com/pts/pdfsizeopt"
EGIT_REPO_URI="https://github.com/pts/pdfsizeopt.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	app-text/ghostscript-gpl
	media-gfx/tif22pnm
	media-gfx/sam2p
"
BDEPEND="${PYTHON_DEPS}"

src_prepare() {
	default
	python_fix_shebang mksingle.py
}

src_compile() {
	./mksingle.py
}

src_install() {
	newbin pdfsizeopt.single pdfsizeopt
}
