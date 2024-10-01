# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google's CJK font family"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-cjk"

COMMIT="4efc595762d1f4b4fa504bccfe8e59de91fda063"
SRC_URI="
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Sans/Variable/OTC/NotoSansCJK-VF.otf.ttc -> NotoSansCJK-VF-${COMMIT}.otf.ttc
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Sans/Variable/OTC/NotoSansMonoCJK-VF.otf.ttc -> NotoSansMonoCJK-VF-${COMMIT}.otf.ttc
	https://github.com/googlefonts/noto-cjk/raw/${COMMIT}/Serif/Variable/OTC/NotoSerifCJK-VF.otf.ttc -> NotoSerifCJK-VF-${COMMIT}.otf.ttc
"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${DISTDIR}"

src_install() {
	insinto /usr/share/fonts/${PN}
	newins NotoSansCJK-VF-${COMMIT}.otf.ttc NotoSansCJK-VF.otf.ttc
	newins NotoSansMonoCJK-VF-${COMMIT}.otf.ttc NotoSansMonoCJK-VF.otf.ttc
	newins NotoSerifCJK-VF-${COMMIT}.otf.ttc NotoSerifCJK-VF.otf.ttc
	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}/70-noto-cjk.conf" # From ArchLinux
}
