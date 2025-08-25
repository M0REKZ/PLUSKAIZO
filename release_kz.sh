#!/usr/bin/env bash
cd "$(dirname "$0")"

make love-zip
make mac-zip
make clean-launcher
make win32-zip
make clean-launcher
make linux64-zip
make clean-launcher
