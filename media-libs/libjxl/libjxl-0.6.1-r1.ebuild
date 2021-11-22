# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS=cmake
inherit cmake-multilib java-pkg-opt-2 xdg-utils

DESCRIPTION="JPEG XL image format reference implementation"
HOMEPAGE="https://github.com/libjxl/libjxl"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libjxl/libjxl.git"
	EGIT_SUBMODULES=(third_party/lodepng third_party/skcms)
else
	LODEPNG_COMMIT="48e5364ef48ec2408f44c727657ac1b6703185f8"
	SKCMS_COMMIT="64374756e03700d649f897dbd98c95e78c30c7da"
	SRC_URI="
		https://github.com/libjxl/libjxl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/lvandeve/lodepng/archive/${LODEPNG_COMMIT}.tar.gz -> lodepng-${LODEPNG_COMMIT}.tar.gz
		https://skia.googlesource.com/skcms/+archive/${SKCMS_COMMIT}.tar.gz -> skcms-${LODEPNG_COMMIT}.tar.gz
	"
fi

LICENSE="Apache-2.0"
SLOT="0/7"
if [[ ${PV} != 9999 ]]; then
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~x86-linux"
fi
IUSE="apng doc gdk-pixbuf gif gimp java +jpeg +man openexr static-libs test +tools viewers"

RDEPEND="app-arch/brotli[${MULTILIB_USEDEP}]
	dev-cpp/highway[${MULTILIB_USEDEP}]
	apng? (
		media-libs/libpng[${MULTILIB_USEDEP}]
		sys-libs/zlib[${MULTILIB_USEDEP}]
	)
	gdk-pixbuf? ( x11-libs/gdk-pixbuf )
	gif? ( media-libs/giflib[${MULTILIB_USEDEP}] )
	gimp? ( media-gfx/gimp:0/2 )
	java? ( >=virtual/jre-1.8:* )
	jpeg? ( virtual/jpeg[${MULTILIB_USEDEP}] )
	openexr? ( media-libs/openexr:= )
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
	java? ( >=virtual/jdk-1.8:* )
"

PATCHES=(
	"${FILESDIR}/roundtripanimationpatches-ifdef-gif.patch"
)

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		rmdir third_party/lodepng
		ln -sv ../../lodepng-${LODEPNG_COMMIT} third_party/lodepng || die
	fi
	use gdk-pixbuf || sed -i -e '/(gdk-pixbuf)/s/^/#/' plugins/CMakeLists.txt || die
	use gimp || sed -i -e '/(gimp)/s/^/#/' plugins/CMakeLists.txt || die
	cmake_src_prepare
	java-pkg-opt-2_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DJPEGXL_ENABLE_BENCHMARK=OFF
		-DJPEGXL_ENABLE_COVERAGE=OFF
		-DJPEGXL_ENABLE_EXAMPLES=OFF
		-DJPEGXL_ENABLE_FUZZERS=OFF
		-DJPEGXL_ENABLE_TOOLS=$(multilib_native_usex tools)
		-DJPEGXL_ENABLE_JNI=$(multilib_native_usex java)
		-DJPEGXL_ENABLE_MANPAGES=$(multilib_native_usex man)
		-DJPEGXL_ENABLE_OPENEXR=$(multilib_native_usex openexr)
		-DJPEGXL_ENABLE_PLUGINS=$(multilib_is_native_abi && echo ON || echo OFF) # USE=gdk-pixbuf, USE=gimp handled in src_prepare
		-DJPEGXL_ENABLE_SJPEG=OFF
		-DJPEGXL_ENABLE_SKCMS=ON
		-DJPEGXL_ENABLE_TCMALLOC=OFF
		-DJPEGXL_ENABLE_VIEWERS=$(multilib_native_usex viewers)

		-DCMAKE_DISABLE_FIND_PACKAGE_PNG=$(multilib_native_usex apng OFF ON)
		-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=$(multilib_native_usex doc OFF ON)
		-DCMAKE_DISABLE_FIND_PACKAGE_GIF=$(multilib_native_usex gif OFF ON)
		-DCMAKE_DISABLE_FIND_PACKAGE_JPEG=$(multilib_native_usex jpeg OFF ON)
	)

	cmake_src_configure
}

multilib_src_test() {
	# DecodeTest.PixelTestWithICCProfileLossy: https://github.com/libjxl/libjxl/issues/500
	# RobustStatisticsTest: https://github.com/libjxl/libjxl/issues/698
	local myctestargs=(
		-E '^DecodeTest\.PixelTestWithICCProfileLossy$|^RobustStatisticsTest\.'
	)
	cmake_src_test
}

multilib_src_install() {
	cmake_src_install
	if ! use static-libs; then
		rm "${ED}"/usr/lib*/*.a || die
	fi
	if use java && multilib_is_native_abi; then
		java-pkg_doso tools/libjxl_jni.so
	fi
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}
