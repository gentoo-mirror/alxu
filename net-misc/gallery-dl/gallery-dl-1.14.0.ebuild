# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=(python{3_6,3_7,3_8})
PYTHON_REQ_USE=(sqlite)

inherit bash-completion-r1 distutils-r1

MY_PN="gallery_dl"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Command-line program to download image-galleries and collections"
HOMEPAGE="https://github.com/mikf/gallery-dl"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

python_install_all() {
	dodoc README.rst

	distutils-r1_python_install_all
}
