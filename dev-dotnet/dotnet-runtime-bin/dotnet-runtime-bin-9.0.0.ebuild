# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION=".NET is a free, cross-platform, open-source developer platform"
HOMEPAGE="https://dotnet.microsoft.com/"

gen_src_uri() {
	echo "$1? (
		elibc_glibc? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-${2:-$1}.tar.gz )
		elibc_musl? ( https://dotnetcli.azureedge.net/dotnet/Runtime/${PV}/dotnet-runtime-${PV}-linux-musl-${2:-$1}.tar.gz )
	)"
}

LICENSE="MIT"
SLOT="$(ver_cut 1-2)"
KEYWORDS="-* ~amd64 ~arm ~arm64"
IUSE="lttng"

SRC_URI="
	$(gen_src_uri amd64 x64)
	$(gen_src_uri arm)
	$(gen_src_uri arm64)
"

RDEPEND="
	sys-libs/zlib:0/1
	!dev-dotnet/dotnet-sdk-bin:${SLOT}
	lttng? ( =dev-util/lttng-ust-2.12* )
"
IDEPEND="
	app-eselect/eselect-dotnet
"

S=${WORKDIR}

QA_PREBUILT="*"
RESTRICT+=" splitdebug"

delete() {
	test -n "$(find . -name "$1" -print -delete)"
}

src_compile() {
	use lttng || delete libcoreclrtraceptprovider.so || die
}

src_install() {
	local dest="opt/${PN}-${SLOT}"
	dodir "${dest%/*}"

	mv "${S}" "${ED}/${dest}" || die
	mkdir "${S}" || die
	fperms 0755 "/${dest}"

	dosym "../../${dest}/dotnet" "/usr/bin/dotnet-bin-${SLOT}"
}

pkg_postinst() {
	eselect dotnet update ifunset
}

pkg_postrm() {
	eselect dotnet update ifunset
}
