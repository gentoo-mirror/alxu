# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal toolchain-funcs flag-o-matic

MY_PV="$(ver_cut 1)_U$(ver_cut 2)"

DESCRIPTION="High level abstract threading library"
HOMEPAGE="https://www.threadingbuildingblocks.org"
SRC_URI="https://github.com/intel/tbb/archive/${MY_PV}.tar.gz -> tbb-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="!=dev-cpp/tbb-2020.3*"
S="${WORKDIR}/oneTBB-${MY_PV}"

src_prepare() {
	default

	# Give it a soname on FreeBSD
	echo 'LIB_LINK_FLAGS += -Wl,-soname=$(BUILDING_LIBRARY)' >>	build/FreeBSD.gcc.inc
	# Set proper versionning on FreeBSD
	sed -i -e '/.DLL =/s/$/.1/' build/FreeBSD.inc || die
}

local_src_compile() {
	local comp arch

	case ${MULTILIB_ABI_FLAG} in
		abi_x86_64) arch=x86_64 ;;
		abi_x86_32) arch=ia32 ;;
#		abi_ppc_64) arch=ppc64 ;;
#		abi_ppc_32) arch=ppc32 ;;
	esac

	case "$(tc-getCXX)" in
		*clang*) comp="clang" ;;
		*g++*) comp="gcc" ;;
		*ic*c) comp="icc" ;;
		*) die "compiler $(tc-getCXX) not supported by build system" ;;
	esac

	tc-export AS CC CXX
	append-cxxflags -Wno-error=changes-meaning

	arch=${arch} \
	CPLUS_FLAGS="${CXXFLAGS}" \
	emake -C "${S}" compiler=${comp} work_dir="${BUILD_DIR}" tbb_root="${S}" cfg=release $@
}

multilib_src_compile() {
	local_src_compile tbb tbbmalloc
}

multilib_src_test() {
	local_src_compile test
}

multilib_src_install() {
	cd "${BUILD_DIR}_release" || die
	local l
	for l in $(find . -name lib\*$(get_libname \*)); do
		dolib.so ${l}
		local bl=$(basename ${l})
		dosym ${bl} /usr/$(get_libdir)/${bl%%.*}$(get_libname)
	done
}
