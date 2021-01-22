# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

MY_PN=pipewire
MY_P=${MY_PN}-${PV}

SRC_URI="https://github.com/PipeWire/${MY_PN}/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="https://pipewire.org/"

LICENSE="LGPL-2.1+"
SLOT="0.2"
IUSE=""

RDEPEND="
	sys-apps/dbus
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

DOCS=()

src_configure() {
	local emesonargs=(
		-Dgstreamer=disabled
		-Dsystemd=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	rm -r ${ED}/{etc,usr/bin}
}
