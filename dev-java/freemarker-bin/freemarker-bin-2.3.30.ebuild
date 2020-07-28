# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit java-pkg-2

DESCRIPTION="A Java tool to generate text output based on templates (binary package)"
HOMEPAGE="https://freemarker.apache.org/"
SRC_URI="https://downloads.apache.org/freemarker/engine/${PV}/binaries/apache-freemarker-${PV}-bin.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="${CP_DEPEND}
	>=virtual/jre-1.7"

S="${WORKDIR}/apache-freemarker-${PV}-bin"

src_install() {
	java-pkg_dojar freemarker.jar
}
