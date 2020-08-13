# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit java-vm-2 toolchain-funcs versionator

abi_uri() {
	echo "${2-$1}? (
		large-heap? (
			debug? (
				https://github.com/AdoptOpenJDK/openjdk${SLOT}-binaries/releases/download/jdk-${DL_PV}/OpenJDK${SLOT}U-debugimage_${1}_linux_openj9_linuxXL_${DL_PV//+/_}.tar.gz
			)
			https://github.com/AdoptOpenJDK/openjdk${SLOT}-binaries/releases/download/jdk-${DL_PV}/OpenJDK${SLOT}U-jdk_${1}_linux_openj9_linuxXL_${DL_PV//+/_}.tar.gz
		)
		!large-heap? (
			debug? (
				https://github.com/AdoptOpenJDK/openjdk${SLOT}-binaries/releases/download/jdk-${DL_PV}/OpenJDK${SLOT}U-debugimage_${1}_linux_openj9_${DL_PV//+/_}.tar.gz
			)
			https://github.com/AdoptOpenJDK/openjdk${SLOT}-binaries/releases/download/jdk-${DL_PV}/OpenJDK${SLOT}U-jdk_${1}_linux_openj9_${DL_PV//+/_}.tar.gz
		)
	)"
}

JDK_PV=$(get_version_component_range 1-3)+$(get_version_component_range 4)
DL_PV=${JDK_PV}_openj9-$(get_version_component_range 5-7)
SLOT=$(get_major_version)

SRC_URI="
	$(abi_uri ppc64le ppc64)
	$(abi_uri x64 amd64)
"

DESCRIPTION="Prebuilt Java JDK binaries provided by AdoptOpenJDK"
HOMEPAGE="https://adoptopenjdk.net"
LICENSE="GPL-2-with-classpath-exception"
KEYWORDS="~amd64 ~ppc64"
IUSE="alsa cups debug doc +gentoo-vm headless-awt large-heap nsplugin selinux source webstart"

RDEPEND="
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	>=sys-apps/baselayout-java-0.1.0-r1
	>=sys-libs/glibc-2.2.5:*
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	doc? ( dev-java/java-sdk-docs:${SLOT} )
	selinux? ( sec-policy/selinux-java )
	!headless-awt? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	)"

PDEPEND="webstart? ( >=dev-java/icedtea-web-1.6.1:0 )
	nsplugin? ( >=dev-java/icedtea-web-1.6.1:0[nsplugin] )"

RESTRICT="preserve-libs splitdebug"
QA_PREBUILT="*"

S="${WORKDIR}/jdk-${JDK_PV}"

pkg_pretend() {
	if [[ "$(tc-is-softfloat)" != "no" ]]; then
		die "These binaries require a hardfloat system."
	fi
}

do_rm() {
	rm -v $* || die
	if use debug ; then
		rm -v ${S}-debug-image/$* || die
	fi
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED%/}/${dest#/}"

	# Not sure why they bundle this as it's commonly available and they
	# only do so on x86_64. It's needed by libfontmanager.so. IcedTea
	# also has an explicit dependency while Oracle seemingly dlopens it.
	do_rm 'lib/libfreetype.*'

	# Oracle and IcedTea have libjsoundalsa.so depending on
	# libasound.so.2 but AdoptOpenJDK only has libjsound.so. Weird.
	if ! use alsa ; then
		do_rm 'lib/libjsound.*'
	fi

	if use headless-awt ; then
		do_rm 'lib/lib*{[jx]awt,splashscreen}*'
	fi

	if ! use source ; then
		rm -v lib/src.zip || die
	fi

	rm -v lib/security/cacerts || die
	dosym ../../../../etc/ssl/certs/java/cacerts \
		"${dest}"/lib/security/cacerts

	dodir "${dest}"
	cp -pPR * "${ddest}" || die

	# provide stable symlink
	dosym "${P}" "/opt/${PN}-${SLOT}"

	use gentoo-vm && java-vm_install-env "${FILESDIR}"/${PN}-${SLOT}.env.sh
	java-vm_set-pax-markings "${ddest}"
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}

pkg_postinst() {
	java-vm-2_pkg_postinst

	if use gentoo-vm ; then
		ewarn "WARNING! You have enabled the gentoo-vm USE flag, making this JDK"
		ewarn "recognised by the system. This will almost certainly break"
		ewarn "many java ebuilds as they are not ready for openjdk-11"
	else
		ewarn "The experimental gentoo-vm USE flag has not been enabled so this JDK"
		ewarn "will not be recognised by the system. For example, simply calling"
		ewarn "\"java\" will launch a different JVM. This is necessary until Gentoo"
		ewarn "fully supports Java 11. This JDK must therefore be invoked using its"
		ewarn "absolute location under ${EPREFIX}/opt/${P}."
	fi
}
