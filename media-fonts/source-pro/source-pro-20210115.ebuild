# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

SANSV="3.046R"
SERIFV="4.004R"
CODEV="2.038R-ro/1.058R-it/1.018R-VAR"

DESCRIPTION="Adobe's open source typeface family designed for UI environments"
HOMEPAGE="https://adobe-fonts.github.io/source-sans/
	https://adobe-fonts.github.io/source-serif/
	https://adobe-fonts.github.io/source-code-pro/"
SRC_URI="https://github.com/adobe-fonts/source-sans/archive/${SANSV}.tar.gz -> source-sans-pro-${PV}.tar.gz
	https://github.com/adobe-fonts/source-serif/archive/${SERIFV}.tar.gz -> source-serif-pro-${PV}.tar.gz
	https://github.com/adobe-fonts/source-code-pro/archive/${CODEV}.tar.gz -> source-code-pro-${PV}.tar.gz"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~x64-macos"
IUSE="cjk"

RESTRICT="binchecks strip"

RDEPEND="
	media-libs/fontconfig
	cjk? ( media-fonts/source-han-sans )
"

FONT_CONF=( "${FILESDIR}"/63-${PN}.conf )
FONT_SUFFIX="otf"

src_prepare() {
	default
	mv source-*/OTF/*.otf . || die
}
