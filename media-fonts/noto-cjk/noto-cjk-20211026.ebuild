# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

COMMIT="9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d"
inherit font

DESCRIPTION="Google's CJK font family"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-cjk"
SRC_URI="
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Sans/Variable/OTC/NotoSansCJK-VF.otf.ttc
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Sans/Variable/OTC/NotoSansMonoCJK-VF.otf.ttc
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Serif/Variable/OTC/NotoSerifCJK-VF.otf.ttc
"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE=""

S=${DISTDIR}

FONT_CONF=( "${FILESDIR}/70-noto-cjk.conf" ) # From ArchLinux
FONT_SUFFIX="ttc"
