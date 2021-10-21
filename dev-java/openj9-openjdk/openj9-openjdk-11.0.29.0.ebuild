# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit check-reqs eapi7-ver flag-o-matic java-pkg-2 java-vm-2 multiprocessing pax-utils toolchain-funcs

SLOT="$(ver_cut 1)"
OPENJ9_PV="$(ver_cut 2-4)"
OPENJ9_P=openj9-${OPENJ9_PV}

DESCRIPTION="Open source implementation of the Java programming language"
HOMEPAGE="https://openjdk.java.net"
if [[ ${OPENJ9_PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ibmruntimes/openj9-openjdk-jdk${SLOT}.git"
	OPENJ9_EGIT_REPO_URI="https://github.com/eclipse/openj9.git"
	OPENJ9_OMR_EGIT_REPO_URI="https://github.com/eclipse/openj9-omr.git"
else
	SRC_URI="
		https://github.com/ibmruntimes/openj9-openjdk-jdk${SLOT}/archive/v${OPENJ9_PV}-release.tar.gz -> openj9-openjdk-jdk${SLOT}-${OPENJ9_P}.tar.gz
		https://github.com/eclipse/openj9/archive/${OPENJ9_P}.tar.gz -> ${OPENJ9_P}.tar.gz
		https://github.com/eclipse/openj9-omr/archive/${OPENJ9_P}.tar.gz -> openj9-omr-${OPENJ9_PV}.tar.gz
	"
fi

LICENSE="GPL-2"
KEYWORDS="~amd64"

IUSE="alsa cups custom-optimization ddr debug doc examples gentoo-vm headless-awt javafx +jbootstrap +pch selinux source systemtap"

COMMON_DEPEND="
	media-libs/freetype:2=
	media-libs/giflib:0/7
	media-libs/harfbuzz:=
	media-libs/libpng:0=
	media-libs/lcms:2=
	sys-libs/zlib
	virtual/jpeg:0=
	systemtap? ( dev-util/systemtap )

	dev-libs/elfutils
	dev-libs/libdwarf
	sys-process/numactl
"

# Many libs are required to build, but not to run, make is possible to remove
# by listing conditionally in RDEPEND unconditionally in DEPEND
RDEPEND="
	${COMMON_DEPEND}
	>=sys-apps/baselayout-java-0.1.0-r1
	!headless-awt? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXt
		x11-libs/libXtst
	)
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	selinux? ( sec-policy/selinux-java )
"

DEPEND="
	${COMMON_DEPEND}
	app-arch/zip
	dev-lang/nasm
	media-libs/alsa-lib
	net-print/cups
	x11-base/xorg-proto
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXtst
	javafx? ( dev-java/openjfx:${SLOT}= )
	|| (
		dev-java/openj9-openjdk-bin:${SLOT}
		dev-java/openj9-openjdk:${SLOT}
		dev-java/openjdk-bin:${SLOT}
		dev-java/openjdk:${SLOT}
	)
"

REQUIRED_USE="javafx? ( alsa !headless-awt )"

S="${WORKDIR}/openj9-openjdk-jdk${SLOT}-${OPENJ9_PV}-release"

# The space required to build varies wildly depending on USE flags,
# ranging from 3GB to 16GB. This function is certainly not exact but
# should be close enough to be useful.
openjdk_check_requirements() {
	local M
	M=3192
	M=$(( $(usex jbootstrap 2 1) * $M ))
	M=$(( $(usex debug 3 1) * $M ))
	M=$(( $(usex doc 320 0) + $(usex source 128 0) + 192 + $M ))

	CHECKREQS_DISK_BUILD=${M}M check-reqs_pkg_${EBUILD_PHASE}
}

pkg_pretend() {
	openjdk_check_requirements
	if [[ ${MERGE_TYPE} != binary ]]; then
		has ccache ${FEATURES} && die "FEATURES=ccache doesn't work with ${PN}, bug #677876"
	fi
}

pkg_setup() {
	openjdk_check_requirements
	java-vm-2_pkg_setup

	JAVA_PKG_WANT_BUILD_VM="openj9-openjdk-${SLOT} openj9-openjdk-bin-${SLOT} openjdk-${SLOT} openjdk-bin-${SLOT}"
	JAVA_PKG_WANT_SOURCE="${SLOT}"
	JAVA_PKG_WANT_TARGET="${SLOT}"

	# The nastiness below is necessary while the gentoo-vm USE flag is
	# masked. First we call java-pkg-2_pkg_setup if it looks like the
	# flag was unmasked against one of the possible build VMs. If not,
	# we try finding one of them in their expected locations. This would
	# have been slightly less messy if openjdk-bin had been installed to
	# /opt/${PN}-${SLOT} or if there was a mechanism to install a VM env
	# file but disable it so that it would not normally be selectable.

	local vm
	for vm in ${JAVA_PKG_WANT_BUILD_VM}; do
		if [[ -d ${EPREFIX}/usr/lib/jvm/${vm} ]]; then
			java-pkg-2_pkg_setup
			return
		fi
	done

	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ -z ${JDK_HOME} ]]; then
			for slot in ${SLOT} $((SLOT-1)); do
				for variant in openj9- ''; do
					if has_version --host-root dev-java/${variant}openjdk:${slot}; then
						JDK_HOME=${EPREFIX}/usr/$(get_libdir)/${variant}openjdk-${slot}
						break
					elif has_version --host-root dev-java/${variant}openjdk-bin:${slot}; then
						JDK_HOME=$(best_version --host-root dev-java/${variant}openjdk-bin:${slot})
						JDK_HOME=${JDK_HOME#*/}
						JDK_HOME=${EPREFIX}/opt/${JDK_HOME%-r*}
						break
					fi
				done
			done
		fi
		[[ -n ${JDK_HOME} ]] || die "Build VM not found!"
		export JDK_HOME
	fi
}

src_unpack() {
	if [[ ${OPENJ9_PV} == 9999 ]]; then
		EGIT_CHECKOUT_DIR=openj9 EGIT_REPO_URI=${OPENJ9_EGIT_REPO_URI} git-r3_src_unpack
		EGIT_CHECKOUT_DIR=openj9-omr EGIT_REPO_URI=${OPENJ9_OMR_EGIT_REPO_URI} git-r3_src_unpack
		# unpack openjdk last to save correct EGIT_VERSION
		EGIT_CHECKOUT_DIR=${S} git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	if [[ ${OPENJ9_PV} == 9999 ]]; then
		ln -s ../openj9 openj9 || die
		ln -s ../openj9-omr omr || die
	else
		ln -s ../openj9-${OPENJ9_P} openj9 || die
		ln -s ../openj9-omr-${OPENJ9_P} omr || die
	fi

	default

	eapply -d openj9 -- "${FILESDIR}/openj9-no-o3.patch"
	eapply -d omr -- "${FILESDIR}/omr-omrstr-iconv-failure-overflow.patch"
	eapply -d omr -- "${FILESDIR}/omr-fam.patch"

	if [[ ${OPENJ9_PV} != 9999 ]]; then
		sed -i -e '/^OPENJDK_SHA :=/s/:=.*/:= __OPENJDK_SHA__/' \
			   -e '/^OPENJ9_SHA :=/s/:=.*/:= '${OPENJ9_P}/ \
			   -e '/^OPENJ9_TAG :=/s/:=.*/:= '${OPENJ9_P}/ \
			   -e '/^OPENJ9OMR_SHA :=/s/:=.*/:= '${OPENJ9_P}/ \
			   closed/OpenJ9.gmk || die
	fi

	find openj9/ omr/ -name CMakeLists.txt -exec sed -i -e '/set(OMR_WARNINGS_AS_ERRORS ON/s/ON/OFF/' {} + || die

	chmod +x configure || die
}

src_configure() {
	# Work around stack alignment issue, bug #647954. in case we ever have x86
	use x86 && append-flags -mincoming-stack-boundary=2

	use custom-optimization || filter-flags '-O*'

	# Enabling full docs appears to break doc building. If not
	# explicitly disabled, the flag will get auto-enabled if pandoc and
	# graphviz are detected. pandoc has loads of dependencies anyway.

	local myconf=(
		--disable-ccache
		--disable-warnings-as-errors{,-omr,-openj9}
		--enable-full-docs=no
		--with-boot-jdk="${JDK_HOME}"
		--with-extra-cflags="${CFLAGS}"
		--with-extra-cxxflags="${CXXFLAGS}"
		--with-extra-ldflags="${LDFLAGS}"
		--with-stdc++lib=dynamic
		--with-freetype=system
		--with-giflib=system
		--with-harfbuzz=system
		--with-lcms=system
		--with-libjpeg=system
		--with-libpng=system
		--with-native-debug-symbols=$(usex debug internal none)
		--with-vendor-name="Gentoo"
		--with-vendor-url="https://gentoo.org"
		--with-vendor-bug-url="https://bugs.gentoo.org"
		--with-vendor-vm-bug-url="https://bugs.openjdk.java.net"
		--with-vendor-version-string="${PVR}"
		--with-version-pre=""
		--with-version-opt=""
		--with-zlib=system
		--enable-dtrace=$(usex systemtap yes no)
		--enable-headless-only=$(usex headless-awt yes no)
		$(tc-is-clang && echo "--with-toolchain-type=clang")

		--with-cmake
		$(use_enable ddr)
	)

	if use javafx; then
		local zip="${EPREFIX%/}/usr/$(get_libdir)/openjfx-${SLOT}/javafx-exports.zip"
		if [[ -r ${zip} ]]; then
			myconf+=( --with-import-modules="${zip}" )
		else
			die "${zip} not found or not readable"
		fi
	fi

	# PaX breaks pch, bug #601016
	if use pch && ! host-is-pax; then
		myconf+=( --enable-precompiled-headers )
	else
		myconf+=( --disable-precompiled-headers )
	fi

	(
		unset _JAVA_OPTIONS JAVA JAVA_TOOL_OPTIONS JAVAC XARGS
		CFLAGS= CXXFLAGS= LDFLAGS= \
		CONFIG_SITE=/dev/null \
		econf "${myconf[@]}"
	)
}

src_compile() {
	local mycmakeargsx=(
		"-DCMAKE_C_FLAGS='${CFLAGS}'"
		"-DJ9JIT_EXTRA_CFLAGS='${CFLAGS}'"
		"-DCMAKE_CXX_FLAGS='${CXXFLAGS}'"
		"-DJ9JIT_EXTRA_CXXFLAGS='${CXXFLAGS}'"
		"-DCMAKE_EXE_LINKER_FLAGS='${LDFLAGS}'"
		-DOMR_WARNINGS_AS_ERRORS=OFF
	)
	local myemakeargs=(
		JOBS=$(makeopts_jobs)
		LOG=debug
		$(usex doc docs '')
		$(usex jbootstrap bootcycle-images product-images)

		EXTRA_CMAKE_ARGS="${mycmakeargsx[*]}"
	)
	emake "${myemakeargs[@]}" -j1 #nowarn
}

src_install() {
	local dest="/usr/$(get_libdir)/${PN}-${SLOT}"
	local ddest="${ED}${dest#/}"

	cd "${S}"/build/*-release/images/jdk || die

	# Create files used as storage for system preferences.
	mkdir .systemPrefs || die
	touch .systemPrefs/.system.lock || die
	touch .systemPrefs/.systemRootModFile || die

	# Oracle and IcedTea have libjsoundalsa.so depending on
	# libasound.so.2 but OpenJDK only has libjsound.so. Weird.
	if ! use alsa ; then
		rm -v lib/libjsound.* || die
	fi

	if ! use examples ; then
		rm -vr demo/ || die
	fi

	if ! use source ; then
		rm -v lib/src.zip || die
	fi

	rm -v lib/security/cacerts || die

	dodir "${dest}"
	cp -pPR * "${ddest}" || die

	dosym ../../../../../etc/ssl/certs/java/cacerts "${dest}"/lib/security/cacerts

	# must be done before running itself
	java-vm_set-pax-markings "${ddest}"

	use gentoo-vm && java-vm_install-env "${FILESDIR}"/${PN}.env.sh
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter

	if use doc ; then
		docinto html
		dodoc -r "${S}"/build/*-release/images/docs/*
		dosym ../../../usr/share/doc/"${PF}" /usr/share/doc/"${PN}-${SLOT}"
	fi
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
		ewarn "fully supports Java ${SLOT}. This JDK must therefore be invoked using its"
		ewarn "absolute location under ${EPREFIX}/usr/$(get_libdir)/${PN}-${SLOT}."
	fi
}
