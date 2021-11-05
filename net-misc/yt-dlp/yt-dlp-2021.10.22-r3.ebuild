# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit bash-completion-r1 distutils-r1 optfeature

DESCRIPTION="youtube-dl fork with additional features and fixes"
HOMEPAGE="https://github.com/yt-dlp/yt-dlp"
SRC_URI="mirror://pypi/${P::1}/${PN}/${P}.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~hppa ~riscv ~x86"

RDEPEND="
	!net-misc/youtube-dl"

distutils_enable_tests pytest

python_test() {
	epytest -m 'not download'
}

python_install_all() {
	dodoc README.md Changelog.md supportedsites.md
	doman yt-dlp.1

	dobashcomp completions/bash/yt-dlp

	insinto /usr/share/fish/vendor_completions.d
	doins completions/fish/yt-dlp.fish

	insinto /usr/share/zsh/site-functions
	doins completions/zsh/_yt-dlp

	rm -r "${ED}"/usr/share/doc/yt_dlp || die

	newbin - youtube-dl <<-EOF
		#!/usr/bin/env sh
		exec yt-dlp --compat-options youtube-dl "\${@}"
	EOF
}

pkg_postinst() {
	if [[ ! ${REPLACING_VERSIONS} ]] ||
		ver_test ${REPLACING_VERSIONS} -lt 2021.10.22-r2; then
		elog 'A wrapper using "yt-dlp --compat-options youtube-dl" was installed'
		elog 'as "youtube-dl". This is strictly for compatibility and it is'
		elog 'recommended to use "yt-dlp" directly, it may be removed in the future.'
	fi
	optfeature 'merging seperate video and audio files as well as for various post-processing tasks' media-video/ffmpeg
	optfeature 'embedding thumbnail in certain formats' media-libs/mutagen
	optfeature 'decrypting AES-128 HLS streams and various other data' dev-python/pycryptodomex
	optfeature 'downloading over websocket' dev-python/websockets
	optfeature 'decrypting cookies of chromium-based browsers on Linux' dev-python/keyring
	optfeature 'embedding thumbnail in mp4/m4a if mutagen is not present' media-video/atomicparsley
	optfeature 'downloading rtmp streams. ffmpeg will be used as a fallback' media-video/rtmpdump
	optfeature 'downloading rstp streams. ffmpeg will be used as a fallback' media-video/mplayer media-video/mpv
}
