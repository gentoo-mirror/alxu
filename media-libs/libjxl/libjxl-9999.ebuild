# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="JPEG XL image format reference implementation"
HOMEPAGE="https://github.com/libjxl/libjxl"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libjxl/libjxl.git"
	EGIT_SUBMODULES=(third_party/lodepng)
else
	LODEPNG_COMMIT="48e5364ef48ec2408f44c727657ac1b6703185f8"
	SRC_URI="
		https://github.com/libjxl/libjxl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/lvandeve/lodepng/archive/${LODEPNG_COMMIT}.tar.gz -> lodepng-${LODEPNG_COMMIT}.tar.gz
	"
fi

LICENSE="Apache-2.0"
SLOT="0"
if [[ ${PV} != 9999 ]]; then
	KEYWORDS="~amd64 ~x86"
fi
IUSE="apng doc gif java jpeg +man openexr static-libs test viewers"

RDEPEND="app-arch/brotli[${MULTILIB_USEDEP}]
	dev-cpp/highway[${MULTILIB_USEDEP}]
	media-libs/lcms[${MULTILIB_USEDEP}]
	apng? (
		media-libs/libpng[${MULTILIB_USEDEP}]
		sys-libs/zlib[${MULTILIB_USEDEP}]
	)
	gif? ( media-libs/giflib[${MULTILIB_USEDEP}] )
	java? ( virtual/jre:* )
	jpeg? ( virtual/jpeg[${MULTILIB_USEDEP}] )
	openexr? ( media-libs/openexr:=[${MULTILIB_USEDEP}] )
	viewers? (
		dev-qt/qtwidgets
		dev-qt/qtx11extras
	)
"
BDEPEND="
	doc? ( app-doc/doxygen )
	man? ( app-text/asciidoc )
	viewers? ( kde-frameworks/extra-cmake-modules )
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest[${MULTILIB_USEDEP}] )
	java? ( virtual/jdk:* )
"

PATCHES=(
	"${FILESDIR}/system-lcms.patch"
	"${FILESDIR}/roundtripanimationpatches-ifdef-gif.patch"
)

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		rmdir third_party/lodepng
		ln -sv ../../lodepng-${LODEPNG_COMMIT} third_party/lodepng || die
	fi
	cmake_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DJPEGXL_ENABLE_BENCHMARK=OFF
		-DJPEGXL_ENABLE_COVERAGE=OFF
		-DJPEGXL_ENABLE_EXAMPLES=OFF
		-DJPEGXL_ENABLE_FUZZERS=OFF
		-DJPEGXL_ENABLE_JNI=$(usex java ON OFF)
		-DJPEGXL_ENABLE_MANPAGES=$(multilib_native_usex man ON OFF)
		-DJPEGXL_ENABLE_OPENEXR=$(usex openexr ON OFF)
		-DJPEGXL_ENABLE_PLUGINS=OFF
		-DJPEGXL_ENABLE_SJPEG=OFF
		-DJPEGXL_ENABLE_SKCMS=OFF
		-DJPEGXL_ENABLE_VIEWERS=$(multilib_native_usex viewers ON OFF)
		-DJPEGXL_FORCE_SYSTEM_GTEST=ON
		-DJPEGXL_FORCE_SYSTEM_BROTLI=ON
		-DJPEGXL_FORCE_SYSTEM_HWY=ON
		-DJPEGXL_FORCE_SYSTEM_LCMS=ON
		-DJPEGXL_WARNINGS_AS_ERRORS=OFF

		$(cmake_use_find_package apng PNG)
		$(cmake_use_find_package apng ZLIB)
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=$(! multilib_is_native_abi || use doc || echo ON)
		$(cmake_use_find_package gif GIF)
		$(cmake_use_find_package jpeg JPEG)
	)

	cmake_src_configure
}

multilib_src_test() {
	# RobustStatisticsTest: https://github.com/libjxl/libjxl/issues/698
	local myctestargs=(
		-E '^RobustStatisticsTest\.'
	)
	cmake_src_test
}

multilib_src_install() {
	cmake_src_install
	if ! use static-libs; then
		rm "${ED}"/usr/$(get_libdir)/libjxl{,_dec}.a || die
	fi
}
