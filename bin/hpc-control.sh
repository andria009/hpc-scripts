#!/bin/bash -e

set -e
set -o pipefail

CONFIG_FILE="$HOME/.hpclipi"
TMPDIR=$(mktemp -d /tmp/hpclipi-XXXXX)

function pinfo() {
	echo -e "\033[32m${1}\033[m" >&2;
}

function pwarn() {
	echo -e "\033[33m${1}\033[m" >&2;
}

function perr() {
	echo -e "\033[31m${1}\033[m" >&2;
}

function swallow() {
	local ERR=0
	"$@" &> "$TMPDIR/log" || ERR=$?

	if [[ $ERR != 0 ]]; then
		perr "+ $*"
		cat "$TMPDIR/log" >&2
	else
		rm -f "$TMPDIR/log"
	fi
	return $ERR
}


#if [[ $(id -u) != 0 ]]; then
#	perr "Command can only be executed by ROOT"
#	exit 5
#fi

MODE=default

while [[ $# -gt 0 ]]; do
	case "$1" in
		--user)
			case "$2" in
				--create)
					pinfo "create user"
					;;
				--delete)
					pinfo "delete user"
					;;
				--modify)
					pinfo "modify user"
					;;
				*)
					pinfo "User Management"
					pinfo ""
					pinfo "Parameters:"
					pinfo "   --create                              # create user"
					pinfo "   --delete                              # delete user"
					pinfo "   --modify                              # modify user"
					;;
			esac
			;;
		--help)
			pinfo "hpc-control.sh: manage LIPI-HPC infrastructure."
			pinfo ""
			pinfo "Normal usage:"
			pinfo "   Follow the instructions."
#			pinfo ""
#			pwarn "Advanced usage:"
#			pwarn "   Parameters:"
#			pwarn "      --lipi | --non-lipi		# applicant's institution is LIPI or non-LIPI"
#			pwarn "      --free | --commercial              # applicant's user type"
#			pwarn "      -r | -u | -i | -o                  # applicant's user institution domain"
#			pwarn "      --queue=XX                         # queue as requested"
#			pwarn "             01                          # Matlab"
#			pwarn "             02                          # Render"
#			pwarn "             03                          # BigMemory - GPU"
#			pwarn "             04                          # BigMemory - NonGPU"
#			pwarn "             05                          # GPU"
#			pwarn "             07                          # NonGPU"
#			pwarn "             08                          # Hadoop"
#			pwarn "      --rin=X                            # RIN Topics"
#			pwarn "             1                           # Universe Science"
#			pwarn "             2                           # Biochemistry/Bioinformatics/Life Sciences"
#			pwarn "             3                           # Chemical Science/Materials"
#			pwarn "             4                           # Earth System Sciences"
#			pwarn "             5                           # Engineering"
#			pwarn "             6                           # Fundamental Constitutes of Matter"
#			pwarn "             7                           # Mathematics and Computer Sciences"
#			pwarn "      --email=[mail@email.com]           # Email"
#			pwarn "      --name=[name]                      # Name"
#			pwarn "      --institution=[instituion]         # Institution"
			;;
		-*)
			perr "Unknown option: $1"
			exit 2
			;;
		*) MODE="$1"
			;;
	esac
#	shift
done

rm -rf "$TMPDIR"
