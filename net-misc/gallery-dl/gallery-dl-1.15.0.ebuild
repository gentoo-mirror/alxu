# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=(python{3_6,3_7,3_8,3_9})
PYTHON_REQ_USE=(sqlite)

inherit distutils-r1

DESCRIPTION="Command-line program to download image-galleries and collections"
HOMEPAGE="https://github.com/mikf/gallery-dl"
SRC_URI="mirror://pypi/g/gallery_dl/gallery_dl-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="test"

RDEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		${RDEPEND}
		dev-python/nose
	)
"

S="${WORKDIR}/gallery_dl-${PV}"

python_test() {
	local noseargs=(
		-v

		# requires network access
		-I 'test_results\.py'
	)
	nosetests "${noseargs[@]}" || die
}

python_install_all() {
	dodoc README.rst

	distutils-r1_python_install_all
}
