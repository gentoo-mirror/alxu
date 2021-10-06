# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker verify-sig xdg

DESCRIPTION="Official RuneScape NXT client launcher"
HOMEPAGE="http://www.runescape.com"
SRC_URI="https://content.runescape.com/downloads/ubuntu/pool/non-free/${PN:0:1}/${PN}/${PN}_${PV}_amd64.deb
	verify-sig? (
		https://content.runescape.com/downloads/ubuntu/dists/trusty/Release -> ${PN}_${PV}_Release
		https://content.runescape.com/downloads/ubuntu/dists/trusty/Release.gpg -> ${PN}_${PV}_Release.gpg
		https://content.runescape.com/downloads/ubuntu/dists/trusty/non-free/binary-amd64/Packages -> ${PN}_${PV}_Packages
	)
"

LICENSE="RuneScape-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="kde"

DEPEND=""
RDEPEND="
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	sys-libs/libcap
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXxf86vm
	dev-libs/openssl
	x11-libs/pango
	media-libs/libsdl2"
BDEPEND="
	verify-sig? ( app-crypt/openpgp-keys-runescape )
"

RESTRICT="bindist mirror strip"
QA_PREBUILT="/usr/share/games/runescape-launcher/runescape"

VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/runescape.gpg.key

S="${WORKDIR}"

src_unpack() {
	if use verify-sig; then
		local Release=${DISTDIR}/${PN}_${PV}_Release
		local Packages=${DISTDIR}/${PN}_${PV}_Packages
		local debfile=${DISTDIR}/${PN}_${PV}_amd64.deb
		local _out

		einfo "Verifying 'Release' file (PGP)..."

		verify-sig_verify_detached "$Release"{,.gpg}

		einfo "Parsing 'Release' file..."

		_out=$(awk 'ok && $3 == "non-free/binary-amd64/Packages" {print $1; exit}
					/^[^[:space:]]/ {ok=0}
					/^SHA256:$/ {ok=1}' < "$Release")
		if ! [[ $_out =~ ^[0-9a-f]{64}$ ]]; then
			die "Could not find hash of 'non-free/binary-amd64/Packages' in the 'Release' file"
		fi

		einfo "Verifying 'Packages' file (SHA256)..."

		if ! sha256sum --quiet --check <<< "$_out *$Packages"; then
			die "Hash sum of 'Packages' did not match expected"
		fi

		einfo "Parsing 'Packages' file..."

		_out=$(awk 'ok && /^SHA256:/ {print $2; exit}
					/^Package:/ {ok=0}
					/^Package: runescape-launcher$/ {ok=1}' < "$Packages")
		if ! [[ $_out =~ ^[0-9a-f]{64}$ ]]; then
			die "Could not find hash of '$debfile' in the 'Packages' file"
		fi

		einfo "Verifying '$debfile' (SHA256)..."

		if ! sha256sum --quiet --check <<< "$_out *$debfile"; then
			die "Hash sum of '$debfile' did not match expected"
		fi
	fi
	unpacker ${PN}_${PV}_amd64.deb
}

src_compile() {
	mv usr/share/doc . || die
	gunzip doc/runescape-launcher/changelog.gz || die
	if ! use kde; then
		rm -r usr/share/kde4 || die
	fi
}

src_install() {
	doins -r usr
	dodoc doc/runescape-launcher/*
}
