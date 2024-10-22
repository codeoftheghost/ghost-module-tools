#!/bin/bash

# Filename  : gmod-add.sh
# Author    : Ghost
# Date      : 2024-10-22
# Desc.     : Script ini berfungsi untuk membuat module .gmod pada distribusi privasi dan anonimitas Ghost Secure Live System (GSLS)
# Version   : 1.0
# License   : GNU General Public License GPLv3.

# Periksa apakah nama aplikasi yang ingin ditambahkan, disertakan sebagai parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-module-dir> <app-name>"
    exit 1
fi

# PEriksa apakah path module disertakan sebagai parameter
if [ -z "$2" ]; then
    echo "Usage: $0 <path-to-module-dir> <app-name>"
    exit 1
fi

MODULE_PATH=$1
APP_NAME=$2

# Periksa apakah aplikasi sudah terinstall di sistem host

# Buat list dari semua file aplikasi yang berada di sistem
APP_LIST_FILE=$(rpm -ql "$APP_NAME")

# Atur IFS untuk memisahkan berdasarkan newline
IFS=$'\n'

# Lakukan pengulangan untuk dan menyalin file
for ITEM in $APP_LIST_FILE; do

    # Melewatkan folder .build-id
    if [[ "$ITEM" == /usr/lib/.build-id* ]]; then
        continue
    fi

    mkdir -p "$MODULE_PATH$(dirname "$ITEM")"
    cp --parents -r "$ITEM" "$MODULE_PATH"
done

# Dynamic library tidak dibutuhkan.
# Bagian ini akan dihapus setelah pengujian.

# DYNAMIC_LIBRARY_LIST=$(ldd "/usr/bin/$APP_NAME" | tr -d '\t')
# for j in $DYNAMIC_LIBRARY_LIST; do
#    if [[ "$j" == /* ]]; then
#         DLL_PATH=$(echo "$j" | awk '{print $1}')
#    elif [[ "$(echo "$j" | awk '{print $2}')" == "=>" ]]; then
#         DLL_PATH=$(echo "$j" | awk '{print $3}')
#     else
#         continue
#     fi

#    mkdir -p "$MODULE_PATH$(dirname "$DLL_PATH")"
#    cp --parents -r "$DLL_PATH" "$MODULE_PATH"
# done

# Kembalikan IFS ke default
unset IFS