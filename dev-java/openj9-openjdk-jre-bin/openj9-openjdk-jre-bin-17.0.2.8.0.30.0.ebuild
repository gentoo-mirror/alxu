# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver java-vm-2 toolchain-funcs

abi_uri() {
	echo "${2-$1}? (
		https://github.com/ibmruntimes/semeru${SLOT}-binaries/releases/download/jdk-${DL_PV/+/%2B}/ibm-semeru-open-jre_${1}_linux_${DL_PV/+/_}.tar.gz
	)"
}

JDK_PV=$(ver_cut 1-3)+$(ver_cut 4)
DL_PV=${JDK_PV}_openj9-$(ver_cut 5-7)
SLOT=$(ver_cut 1)

SRC_URI="
	$(abi_uri aarch64 arm64)
	$(abi_uri ppc64le ppc64)
	$(abi_uri s390x s390)
	$(abi_uri x64 amd64)
"

DESCRIPTION="Prebuilt IBM Semeru JRE binaries provided by IBM"
HOMEPAGE="https://developer.ibm.com/languages/java/semeru-runtimes/"
LICENSE="GPL-2-with-classpath-exception"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~s390"
IUSE="alsa cups +gentoo-vm headless-awt selinux"

RDEPEND="
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	>net-libs/libnet-1.1
	>=sys-apps/baselayout-java-0.1.0-r1
	>=sys-libs/glibc-2.2.5:*
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	selinux? ( sec-policy/selinux-java )
	!headless-awt? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	)"

RESTRICT="preserve-libs splitdebug"
QA_PREBUILT="*"

S="${WORKDIR}/jdk-${JDK_PV}-jre"

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED%/}/${dest#/}"

	# Oracle and IcedTea have libjsoundalsa.so depending on
	# libasound.so.2 but AdoptOpenJDK only has libjsound.so. Weird.
	if ! use alsa ; then
		rm -v lib/libjsound.* || die
	fi

	if use headless-awt ; then
		rm -v lib/lib*{[jx]awt,splashscreen}* || die
	fi

	rm -v lib/security/cacerts || die
	dosym ../../../../etc/ssl/certs/java/cacerts "${dest}"/lib/security/cacerts

	dodir "${dest}"
	cp -pPR * "${ddest}" || die

	# provide stable symlink
	dosym "${P}" "/opt/${PN}-${SLOT}"

	use gentoo-vm && java-vm_install-env "${FILESDIR}"/${PN}.env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}
