#!/usr/bin/env bash
repo_url="${1:-https://github.com/Klipper3d/Klipper.git}"
git ls-remote -q "${repo_url}"  master | cut -f 1 -d "	" | cut -c 1-7 
