#!/usr/bin/env bash
repo_url="${1:-https://github.com/Arksine/CanBoot.git}"
ref="${1-master}"
git ls-remote -q "${repo_url}" "${ref}" | cut -f 1 -d "	" | cut -c 1-7 
