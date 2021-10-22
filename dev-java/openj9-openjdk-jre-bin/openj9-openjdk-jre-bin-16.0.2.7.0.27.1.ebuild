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
	$(abi_uri ppc64le ppc64)
"

DESCRIPTION="Prebuilt IBM Semeru JRE binaries provided by IBM"
HOMEPAGE="https://developer.ibm.com/languages/java/semeru-runtimes/"
LICENSE="GPL-2-with-classpath-exception"
KEYWORDS="~ppc64"
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

pkg_postinst() {
	java-vm-2_pkg_postinst

	if use gentoo-vm ; then
		ewarn "WARNING! You have enabled the gentoo-vm USE flag, making this JRE"
		ewarn "recognised by the system. This will almost certainly break things."
	else
		ewarn "The experimental gentoo-vm USE flag has not been enabled so this JRE"
		ewarn "will not be recognised by the system. For example, simply calling"
		ewarn "\"java\" will launch a different JVM. This is necessary until Gentoo"
		ewarn "fully supports Java 11. This JRE must therefore be invoked using its"
		ewarn "absolute location under ${EPREFIX}/opt/${P}."
	fi
}
