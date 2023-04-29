#!/bin/bash
git clone --depth 1 -b "${1:-master}" "https://github.com/klipper3d/klipper.git" "$HOME/klipper"
