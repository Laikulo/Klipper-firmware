#!/usr/bin/env bash

script_dir="$(dirname "$0")"
cd "${script_dir}/.."

klipper_ver="$("${script_dir}/latest-klipper.sh" "https://github.com/Laikulo/klipper.git" "laikulo-devel")"
canboot_ver="$("${script_dir}/latest-canboot.sh")"

"${script_dir}/factory-all.sh" "${klipper_ver}"
"${script_dir}/cannery-all.sh" "${canboot_ver}"
