# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit xdg cmake git-r3

DESCRIPTION="JPEG XL image format reference implementation"
HOMEPAGE="https://github.com/libjxl/libjxl"

EGIT_REPO_URI="https://github.com/libjxl/libjxl.git"
EGIT_SUBMODULES=(third_party/lodepng third_party/skcms)

LICENSE="Apache-2.0"
SLOT="0"
IUSE="apng doc gif jpeg +man openexr test viewers"

DEPEND="app-arch/brotli
	dev-libs/highway
	virtual/opengl
	apng? (
		media-libs/libpng
		sys-libs/zlib
	)
	doc? ( app-doc/doxygen )
	gif? ( media-libs/giflib )
	jpeg? ( virtual/jpeg )
	man? ( app-text/asciidoc )
	openexr? ( media-libs/openexr )
	test? ( dev-cpp/gtest )
	viewers? (
		dev-qt/qtwidgets
		dev-qt/qtx11extras
	)
"

BDEPEND=""

RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DJPEGXL_ENABLE_BENCHMARK=OFF
		-DJPEGXL_ENABLE_COVERAGE=OFF
		-DJPEGXL_ENABLE_EXAMPLES=ON
		-DJPEGXL_ENABLE_FUZZERS=OFF
		-DJPEGXL_ENABLE_MANPAGES=$(usex man ON OFF)
		-DJPEGXL_ENABLE_OPENEXR=$(usex openexr ON OFF)
		-DJPEGXL_ENABLE_PLUGINS=OFF
		-DJPEGXL_ENABLE_SJPEG=OFF
		-DJPEGXL_ENABLE_VIEWERS=$(usex viewers ON OFF)
		-DJPEGXL_FORCE_SYSTEM_BROTLI=ON
		-DJPEGXL_WARNINGS_AS_ERRORS=OFF

		$(cmake_use_find_package gif GIF)
		$(cmake_use_find_package jpeg JPEG)
		$(cmake_use_find_package png PNG)
		$(cmake_use_find_package doc Doxygen)
	)

	cmake_src_configure
}
