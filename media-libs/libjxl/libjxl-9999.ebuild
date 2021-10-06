# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit xdg cmake

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
IUSE="apng doc gif gdk-pixbuf gimp java jpeg +man openexr static-libs test viewers"

RDEPEND="app-arch/brotli
	dev-cpp/highway
	media-libs/lcms
	apng? (
		media-libs/libpng
		sys-libs/zlib
	)
	gdk-pixbuf? ( x11-libs/gdk-pixbuf )
	gif? ( media-libs/giflib )
	gimp? ( media-gfx/gimp )
	java? ( virtual/jdk:* )
	jpeg? ( virtual/jpeg )
	man? ( app-text/asciidoc )
	openexr? ( media-libs/openexr:= )
	viewers? (
		kde-frameworks/extra-cmake-modules
		dev-qt/qtwidgets
		dev-qt/qtx11extras
	)
"
BDEPEND="
	doc? ( app-doc/doxygen )
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
"

PATCHES=("${FILESDIR}/system-lcms.patch")

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		rmdir third_party/lodepng
		ln -sv ../../lodepng-${LODEPNG_COMMIT} third_party/lodepng || die
	fi
	use gdk-pixbuf || sed -i -e '/(gdk-pixbuf)/s/^/#/' plugins/CMakeLists.txt || die
	use gimp || sed -i -e '/(gimp)/s/^/#/' plugins/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DJPEGXL_ENABLE_BENCHMARK=OFF
		-DJPEGXL_ENABLE_COVERAGE=OFF
		-DJPEGXL_ENABLE_EXAMPLES=OFF
		-DJPEGXL_ENABLE_FUZZERS=OFF
		-DJPEGXL_ENABLE_JNI=$(usex java ON OFF)
		-DJPEGXL_ENABLE_MANPAGES=$(usex man ON OFF)
		-DJPEGXL_ENABLE_OPENEXR=$(usex openexr ON OFF)
		-DJPEGXL_ENABLE_PLUGINS=ON # USE=gdk-pixbuf, USE=gimp handled in src_prepare
		-DJPEGXL_ENABLE_SJPEG=OFF
		-DJPEGXL_ENABLE_SKCMS=OFF
		-DJPEGXL_ENABLE_VIEWERS=$(usex viewers ON OFF)
		-DJPEGXL_FORCE_SYSTEM_GTEST=ON
		-DJPEGXL_FORCE_SYSTEM_BROTLI=ON
		-DJPEGXL_FORCE_SYSTEM_HWY=ON
		-DJPEGXL_FORCE_SYSTEM_LCMS=ON

		$(cmake_use_find_package apng PNG)
		$(cmake_use_find_package apng ZLIB)
		$(cmake_use_find_package doc Doxygen)
		$(cmake_use_find_package gif GIF)
		$(cmake_use_find_package jpeg JPEG)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	if ! use static-libs; then
		rm "${ED}"/usr/$(get_libdir)/libjxl{,_dec}.a || die
	fi
}
