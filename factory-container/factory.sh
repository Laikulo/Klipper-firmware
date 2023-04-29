#!/bin/bash

# Factory script for building klipper


function print_usage() {
	cat <<-END
	Usage: $0 [options] <-c config_file> | <-C test_name> - Klipper factory builder
	options:
	-c The path to the Kconfig to build with
	-C The name of a built-in test config to build
	-h This help
	-v Verbose builds
	END
}

function die() {
	# (message, rc, usage)
	# Print an error mesage and terminate with the given return code,
	# optionally, print the usage after the message
	echo >&2 "$1"
	[[ $3 ]] && print_usage >&2
	exit ${2:-1}
}

function one(){
	# (...)
	# Returns true if one (and only one) of the arguments is non-empty
	local found=""
	for i in $(seq 0 $#); do
		if [[ $1 ]]; then
			if [[ $found ]]; then
				return 1
			else
				found="y"
			fi
		fi
		if [[ $# -gt 0 ]]; then
			shift 1
		fi
	done
	[[ $found ]]
	return $?
}

function any(){
	# (...)
	# Returns true if any of the arguments is non-empty
	for i in $(seq 0 $#); do
		if [[ $1 ]]; then
			return 0
		fi
		if [[ $# -gt 0 ]]; then
			shift 1
		fi
	done
	return 1
}

function coalesce(){
	#(...)
	# Prints the first nonempty arg
	for i in $(seq 0 $#); do
		if [[ $1 ]]; then
			echo "$1"
			return 0
		fi
		if [[ $# -gt 0 ]]; then
			shift 1
		fi
	done
	return 1
}


function main(){

OPT_VERBOSE=""
OPT_EXPLICIT_CONFIG=""
OPT_TEST_CONFIG=""
OPT_KLIPPER_DIR=""

ARGS_BAD=""

while getopts "vhc:C:d:" arg; do
	case $arg in
		h)
			print_usage
			exit 0
			;;
		v)
			OPT_VERBOSE=1
			;;
		c)
			OPT_EXPLICIT_CONFIG="${OPTARG}"
			;;
		C)
			OPT_TEST_CONFIG="${OPTARG}"
			;;
		d)
			OPT_KLIPPER_DIR="${OPTARG}"
			;;
		?)
			ARGS_BAD=1
			;;
			
	esac

done

[[ $ARGS_BAD ]] && die "FATAL: Unkown Option(s)" 2 y

## Validation of options
any "$OPT_EXPLICIT_CONFIG" "$OPT_TEST_CONFIG" "$KLIPPER_FACTORY_CONFIG_FILE" "$KLIPPER_FACTORY_TESTCONFIG_NAME" || die "Build config is not specified" 2 y
one "$OPT_EXPLICIT_CONFIG" "$OPT_TEST_CONFIG" "$KLIPPER_FACTORY_CONFIG_FILE" "$KLIPPER_FACTORY_TESTCONFIG_NAME" || die "Build config is specified more than once" 2 y

one "$OPT_KLIPPER_DIR" "$KLIPPER_DIR" || die "Klipper directory not specified" 2 y

local klipper_workdir="$(coalesce "$OPT_KLIPPER_DIR" "$KLIPPER_DIR")"

local test_config="$(coalesce "$OPT_TEST_CONFIG" "$KLIPPER_FACTORY_CONFIG_FILE")"


if [[ $test_config ]]; then
	config_path="${klipper_workdir}/test/configs/${test_config}.config"
else
	config_path="$(realpath "$(coalesce "$OPT_EXPLICIT_CONFIG" "$KLIPPER_FACTORY_CONFIG_FILE")")"
fi

[[ $OPT_VERBOSE ]] && echo >&2 "Using build config at $config_path"
[[ -f $config_path ]] || die "Config file $config_path does not exist"
[[ -r $config_path ]] || die "Config file $config_path is not readable"

config_name="$(basename $config_path)"
config_name="${config_name%.config}"

set -e
cd "$klipper_workdir"
echo >&2 "Cleaning the working environment"
make clean
git clean -fdx

local klipper_ver="$(git describe --always --tags --long --dirty)"
local tag_name="$klipper_ver-$config_name"
echo >&2 "Placing config file"
cp "$config_path" .config
echo >&2 "Configuring"
make olddefconfig
echo >&2 "Building"
make
echo >&2 "Collecting results"
[[ -d ../dist ]] || mkdir ../dist
local distdir="../dist/klipper-fw-$tag_name"
[[ -d $distdir ]] || mkdir $distdir
distdir="$(realpath "$distdir")"

cp out/klipper.* "$distdir"
cd "$distdir"
for i in klipper.*; do
	mv "$i" "${i/klipper/klipper-$config_name}"
done
echo >&2 Built: klipper-* in "$distdir"

tar -czf "$distdir/../klipper-fw-$tag_name.tgz" -C "$distdir/.." "$(basename "$distdir")"

echo >&2 Created Archive at "$(realpath $distdir/../klipper-fw-$tag_name.tgz)"

echo >&2 "Complete"
	
}

main "$@"