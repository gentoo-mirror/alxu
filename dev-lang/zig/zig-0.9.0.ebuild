# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LLVM_MAX_SLOT=13
inherit cmake llvm

DESCRIPTION="A robust, optimal, and maintainable programming language"
HOMEPAGE="https://ziglang.org/"
if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/ziglang/zig.git"
	inherit git-r3
else
	SRC_URI="https://github.com/ziglang/zig/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="!test? ( test )"

BUILD_DIR="${S}/build"

# According to zig's author, zig builds that do not support all targets are not
# supported by the upstream project.
ALL_LLVM_TARGETS=(
	AArch64 AMDGPU ARM AVR BPF Hexagon Lanai Mips MSP430 NVPTX
	PowerPC RISCV Sparc SystemZ WebAssembly X86 XCore
)
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS="${ALL_LLVM_TARGETS[@]/%/(-)?}"

IUSE="test ${ALL_LLVM_TARGETS[*]}"

RDEPEND="
	sys-devel/clang:${LLVM_MAX_SLOT}
	>=sys-devel/lld-${LLVM_MAX_SLOT}
	<sys-devel/lld-$((${LLVM_MAX_SLOT} + 1))
	sys-devel/llvm:${LLVM_MAX_SLOT}[${LLVM_TARGET_USEDEPS// /,}]
"
DEPEND="${RDEPEND}"

llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
}

src_configure() {
	local mysedargs=() llvm_target arch
	for target in "${ALL_LLVM_TARGETS[@]}"; do
		if ! use $target; then
			llvm_target=${target#llvm_targets_}
			case $llvm_target in
				AArch64) arch=(aarch64 aarch64_be aarch64_32);;
				AMDGPU) arch=(amdgcn);;
				ARM) arch=(thumb thumbeb arm armeb);;
				AVR) arch=(avr);;
				BPF) arch=(bpfel bpfeb);;
				Hexagon) arch=(hexagon);;
				Lanai) arch=(lanai);;
				Mips) arch=(mips mipsel mips64 mips64el);;
				MSP430) arch=(msp430);;
				NVPTX) arch=(nvptx nvptx64);;
				PowerPC) arch=(powerpc powerpcle powerpc64 powerpc64le);;
				RISCV) arch=(riscv32 riscv64);;
				Sparc) arch=(sparc sparcv9 sparcel);;
				SystemZ) arch=(s390x);;
				WebAssembly) arch=(wasm32 wasm64);;
				X86) arch=(i386 x86_64);;
				XCore) arch=(xcore);;
				*) die "unhandled target"
			esac
			for a in ${arch[@]}; do
				mysedargs+=(
					-e "/^pub fn targetTriple(/,/^}/s/\.$a => .*/.$a => return error.@\"Zig compiled without LLVM $llvm_target\",/"
				)
			done
			mysedargs+=(
				-e "/^fn initializeLLVMTarget(/,/^}/ {
						/\.$a => {/,/},$/ {
							s/=>.*/=> unreachable,/
							/=>/!d
						}
					}"
			)
		fi
	done
	sed -i "${mysedargs[@]}" src/codegen/llvm.zig || die

	local mycmakeargs=(
		-DZIG_USE_CCACHE=OFF
		-DZIG_PREFER_CLANG_CPP_DYLIB=ON
	)

	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}" || die
	./zig build test || die
}
