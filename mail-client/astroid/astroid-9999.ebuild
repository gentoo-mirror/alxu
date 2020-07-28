# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

: "${CMAKE_MAKEFILE_GENERATOR:=ninja}"

inherit cmake git-r3 virtualx

DESCRIPTION="lightweight graphical threads-with-tags style email client for notmuch"
HOMEPAGE="https://github.com/astroidmail/astroid"
EGIT_REPO_URI="https://github.com/astroidmail/astroid.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="+doc embedded-editor plugins profile terminal test"

RDEPEND="
	plugins? (
		dev-libs/gobject-introspection
		>=dev-libs/libpeas-1.0.0
		|| (
			dev-libs/gmime:3.0[vala]
			dev-libs/gmime:2.6[vala]
		)
	)
	terminal? (
		x11-libs/vte:2.91
	)
	|| (
		>=dev-libs/gmime-3.0.3:3.0
		>=dev-libs/gmime-2.6.21:2.6
	)
	dev-cpp/glibmm:2
	>=dev-cpp/gtkmm-3.10:3.0[X]
	dev-libs/boost[nls]
	dev-libs/libsass
	>=dev-libs/protobuf-3.6.0:=
	net-libs/libsoup:2.4
	>=net-libs/webkit-gtk-2.22.0:4
	net-mail/notmuch
"
DEPEND="${RDEPEND}
	doc? (
		|| (
			app-text/scdoc
			app-text/ronn
		)
	)
	test? (
		${VIRTUALX_DEPEND}
		app-crypt/gnupg
		app-text/cmark
	)
	virtual/pkgconfig
"

src_prepare() {
	if ! use test; then
		sed -i -e '/enable_testing/d;/add_subdirectory.*tests.*/d' CMakeLists.txt
		rm -rf tests
	fi

	if use terminal; then
		sed -i -e '/pkg_check_modules.*VTE2/s/VTE2/VTE2 REQUIRED/' CMakeLists.txt
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDISABLE_DOCS=$(usex doc OFF ON)
		-DDISABLE_EMBEDDED_EDITOR=$(usex embedded-editor OFF ON)
		-DDISABLE_TERMINAL=$(usex terminal OFF ON)
		-DDISABLE_PLUGINS=$(usex plugins OFF ON)
		-DENABLE_PROFILING=$(usex profile ON OFF)
	)

	cmake_src_configure
}

src_test() {
	virtx cmake_src_test
}

pkg_postinst() {
	optfeature "GnuPG" app-crypt/gnupg
	optfeature "Markdown" app-text/cmark
}
