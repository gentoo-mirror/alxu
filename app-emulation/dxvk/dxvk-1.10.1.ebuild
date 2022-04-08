# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit flag-o-matic meson multilib-minimal

DESCRIPTION="Vulkan-based implementation of D3D9, D3D10 and D3D11 for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/doitsujin/dxvk.git"
else
	SRC_URI="https://github.com/doitsujin/dxvk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="ZLIB"
SLOT="0"
if [[ "${PV}" == "9999" ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi
IUSE="+d3d9 +d3d10 +d3d11 debug +dxgi test"

DEPEND="
	dev-util/vulkan-headers
	dev-util/glslang
"
RDEPEND="
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	|| (
		>=app-emulation/wine-staging-4.5[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-vanilla-4.5[${MULTILIB_USEDEP},vulkan]
	)
"

PATCHES=(
	"${FILESDIR}/dxvk-1.8_add-compiler-flags.patch"
)

RESTRICT="!test? ( test )"

patch_build_flags() {
	local bits="${MULTILIB_ABI_FLAG:8:2}"

	# Fix installation directory.
	sed -i "s|\"x${bits}\"|\"usr/$(get_libdir)/dxvk\"|" setup_dxvk.sh || die

	# Add *FLAGS to cross-file.
	sed -i \
		-e "s!@CFLAGS@!$(_meson_env_array "${CFLAGS}")!" \
		-e "s!@CXXFLAGS@!$(_meson_env_array "${CXXFLAGS}")!" \
		-e "s!@LDFLAGS@!$(_meson_env_array "${LDFLAGS}")!" \
		"build-win${bits}.txt" || die
}

src_prepare() {
	default

	sed -i "s|^basedir=.*$|basedir=\"${EPREFIX}\"|" setup_dxvk.sh || die

	# Delete installation instructions for unused ABIs.
	if ! use abi_x86_64; then
		sed -i '/installFile "$win64_sys_path"/d' setup_dxvk.sh || die
	fi
	if ! use abi_x86_32; then
		sed -i '/installFile "$win32_sys_path"/d' setup_dxvk.sh || die
	fi

	multilib_foreach_abi patch_build_flags

	# Load configuration file from /etc/dxvk.conf.
	sed -Ei 's|filePath = "^(\s+)dxvk.conf";$|\1filePath = "/etc/dxvk.conf";|' \
		src/util/config/config.cpp || die
}

multilib_src_configure() {
	local bits="${MULTILIB_ABI_FLAG:8:2}"

	local emesonargs=(
		--libdir="$(get_libdir)/dxvk"
		--bindir="$(get_libdir)/dxvk"
		--cross-file="${S}/build-win${bits}.txt"
		--buildtype="release"
		$(usex debug "" "--strip")
		$(meson_use d3d9 "enable_d3d9")
		$(meson_use d3d10 "enable_d3d10")
		$(meson_use d3d11 "enable_d3d11")
		$(meson_use dxgi "enable_dxgi")
		$(meson_use test "enable_tests")
	)
	meson_src_configure
}

multilib_src_compile() {
	EMESON_SOURCE="${S}"
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	# The .a files are needed during the install phase.
	find "${D}" -name '*.a' -delete -print

	dobin setup_dxvk.sh

	insinto etc
	doins "dxvk.conf"

	default
}
