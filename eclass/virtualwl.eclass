# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: virtualwl.eclass
# @MAINTAINER:
# alex_y_xu@yahoo.ca
# @AUTHOR:
# Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Similar to virtualx.eclass, but using Wayland.

case ${EAPI} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} unsupported."
esac

if [[ ! ${_VIRTUALWL_ECLASS} ]]; then
_VIRTUALWL_ECLASS=1

# @ECLASS-VARIABLE: VIRTUALWL_REQUIRED
# @PRE_INHERIT
# @DESCRIPTION:
# Variable specifying the dependency on wayland.
# Possible special values are "always" and "manual", which specify
# the dependency to be set unconditionally or not at all.
# Any other value is taken as useflag desired to be in control of
# the dependency (eg. VIRTUALWL_REQUIRED="kde" will add the dependency
# into "kde? ( )" and add kde into IUSE.
: ${VIRTUALWL_REQUIRED:=test}

# @ECLASS-VARIABLE: VIRTUALWL_DEPEND
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Standard dependencies string that is automatically added to BDEPEND
# unless VIRTUALWL_REQUIRED is set to "manual".
readonly VIRTUALWL_DEPEND="
	gui-wm/tinywl
"

case ${VIRTUALWL_REQUIRED} in
	manual)
		;;
	always)
		BDEPEND="${VIRTUALWL_DEPEND}"
		;;
	*)
		BDEPEND="${VIRTUALWL_REQUIRED}? ( ${VIRTUALWL_DEPEND} )"
		IUSE="${VIRTUALWL_REQUIRED}"
		[[ ${VIRTUALWL_REQUIRED} == "test" ]] &&
			RESTRICT+=" !test? ( test )"
		;;
esac

# @FUNCTION: virtwl
# @USAGE: <command> [command arguments]
# @DESCRIPTION:
# Start a new wayland session and run commands in it.
#
# IMPORTANT: This command is run nonfatal !!!
#
# This means we are checking for the return code and raise an exception if it
# isn't 0. So you need to make sure that all commands return a proper
# code and not just die. All eclass function used should support nonfatal
# calls properly.
#
# The rationale behind this is the tear down of the started wayland session. A
# straight die would leave a running session behind.
#
# Example:
#
# @CODE
# src_test() {
#     virtwl default
# }
# @CODE
#
# @CODE
# python_test() {
#     virtwl py.test --verbose
# }
# @CODE
#
# @CODE
# my_test() {
#   some_command
#   return $?
# }
#
# src_test() {
#	  virtwl my_test
# }
# @CODE
virtwl() {
	debug-print-function ${FUNCNAME} "$@"

	[[ $# -lt 1 ]] && die "${FUNCNAME} needs at least one argument"
	[[ -n $XDG_RUNTIME_DIR ]] || die "${FUNCNAME} needs XDG_RUNTIME_DIR to be set; try xdg_environment_reset"
	tinywl -h >/dev/null || die 'tinywl -h failed'

	# TODO: don't run addpredict in utility function. WLR_RENDERER=pixman doesn't work
	addpredict /dev/dri
	coproc VIRTWL { WLR_BACKENDS=headless exec tinywl -s 'echo $WAYLAND_DISPLAY'; }
	local -x WAYLAND_DISPLAY
	read WAYLAND_DISPLAY <&${VIRTWL[0]}

	debug-print "${FUNCNAME}: $@"
	nonfatal "$@"
	retval=$?

	[[ -n $VIRTWL_PID ]] || die "tinywl exited unexpectedly"
	kill $VIRTWL_PID

	[[ $retval = 0 ]] || die "Failed to run '$@'"
}
fi
