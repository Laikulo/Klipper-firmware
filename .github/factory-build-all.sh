#!/usr/bin/env bash
set -e -x
typeset -a conflist
conflist=("factory-configs/"*".config")
for conf in "${conflist[@]}"; do
	conf_dir="$(dirname "${conf}")"
	conf_name="$(basename "${conf}")"
	out_dir="$PWD/dist"
	tmp_dir="$(mktemp -d -t klipperfactory.XXXXXXXXXX)"
	tmp_conf="${tmp_dir}/conf"
	tmp_out="${tmp_dir}/out"
	mkdir "${tmp_conf}" "${tmp_out}"
	cp "$conf" "${tmp_conf}/${conf_name}"
	docker run --rm -v "${tmp_conf}:/mnt/conf:z" -v "${tmp_out}:/mnt/out:z" "ghcr.io/laikulo/klipper-firmware/factory:${1:-laikulo}" -c "/mnt/conf/${conf_name}" -o "/mnt/out"
	cp -r "${tmp_out}/"*"."* "${out_dir}"
	rm -rf "${tmp_dir}"
done
