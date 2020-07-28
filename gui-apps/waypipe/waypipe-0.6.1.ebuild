# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit meson python-any-r1

DESCRIPTION="proxy for Wayland clients"
HOMEPAGE="https://gitlab.freedesktop.org/mstoeckl/waypipe"
SRC_URI="https://gitlab.freedesktop.org/mstoeckl/waypipe/-/archive/v0.6.1/waypipe-v0.6.1.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+drm ffmpeg lz4 +man test vaapi zstd"

REQUIRED_USE="vaapi? ( ffmpeg )"

DEPEND="
	dev-libs/wayland
	drm? ( x11-libs/libdrm )
	ffmpeg? ( virtual/ffmpeg )
	lz4? ( app-arch/lz4:= )
	vaapi? ( x11-libs/libva )
	zstd? ( app-arch/zstd:= )
"
RDEPEND="${DEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-libs/wayland-protocols
	man? ( app-text/scdoc )
	test? ( dev-libs/weston )
"

S="${WORKDIR}/${PN}-v${PV}"

src_configure() {
	local emesonargs=(
		-Dwerror=false
		$(meson_feature man man-pages)
		$(meson_feature ffmpeg with_video)
		$(meson_feature drm with_dmabuf)
		$(meson_feature lz4 with_lz4)
		$(meson_feature zstd with_zstd)
		$(meson_feature vaapi with_vaapi)
	)
	meson_src_configure
}
