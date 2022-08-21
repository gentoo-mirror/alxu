# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Java Runtime Environment (JRE)"
SLOT="${PV}"
KEYWORDS=""

RDEPEND="|| (
		dev-java/openjdk-jre-bin:${SLOT}[gentoo-vm(+)]
		dev-java/openj9-openjdk-jre-bin:${SLOT}[gentoo-vm(+)]
		virtual/jdk:${SLOT}
)"
