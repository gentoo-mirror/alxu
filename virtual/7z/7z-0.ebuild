# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for /usr/bin/7z"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="|| ( app-arch/7-zip app-arch/p7zip )"
