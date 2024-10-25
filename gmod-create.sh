#!/bin/bash

# Filename  : gmod-add.sh
# Author    : Ghost
# Date      : 2024-10-22
# Desc.     : Script ini berfungsi untuk membuat module .sb pada distribusi privasi dan anonimitas Ghost Secure Live System (GSLS)
# Version   : 1.0
# License   : GNU General Public License GPLv3.

# Periksa apakah path module disertakan sebagai parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-module-dir> <app-name>"
    exit 1
fi

# PEriksa apakah nama dari module baru disertakan sebagai parameter
if [ -z "$2" ]; then
    echo "Usage: $0 <path-to-module-dir> <app-name>"
    exit 1
fi

MODULE_PATH=$1
NEW_MODULE_NAME=$2

# Mulai proses untuk membuat module baru
echo "Begin process to create new module."
echo ""

mksquashfs "$1" "$2".sb -comp xz -e "lost+found"

echo ""
echo "New module $2.sb successfully creted."