# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Precomp, C++ version - further compress already compressed files"
HOMEPAGE="https://github.com/schnaader/precomp-cpp"
SRC_URI="https://github.com/schnaader/precomp-cpp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

PATCHES=(
	"${FILESDIR}/add_compile_definitions.patch"
)

src_install() {
	dobin "${BUILD_DIR}/precomp"
}
