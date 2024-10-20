#!/bin/bash

# Filename  : gmod-activate.sh
# Author    : Ghost
# Date      : 2024-10-20
# Desc.     : Script ini berfungsi untuk mengaktifkan module .gmod pada distribusi privasi dan anonimitas Ghost Secure Live System (GSLS)
# Version   : 1.0
# License   : GNU General Public License GPLv3.

# Periksa apakah module .gmod disertakan sebagai parameter
if [ -z "S1" ]; then
    echo "Usage: $0 <path-to-mmodule.gmo>"
    exit 1
fi

MODULE_PATH=$1
MODULE_NAME=$(basename "$MODULE_PATH" .gmod)
MOUNT_POINT="/mnt/$MODULE_NAME"

# Mengecek apakah module yang disertakan memiliki ekstensi file .gmod
if [[ "$MODULE_PATH" != *.gmod ]]; then
    echo "Error: File is not a .gmod module"
    exit 1
fi

# Membuat direktori mount point untuk module
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Mount module dengan opsi read-only kedalam direktori mount
echo "Mounting $MODULE_PATH to $MOUNT_POINT"
mount -o loop,ro "$MODULE_PATH" "$MOUNT_POINT"

# Overlay hasil mount module ke root filesyste
if [ ! -d "/union" ]; then
    mkdir /union
fi

mount -t overlay overlay -o lowerdir="$MOUNT_POINT",upperdir=/,workdir=/union /

# Dynamic linking dan update cache library
echo "Updating library cache"
ldconfig

echo "Module $MODULE_PATH has been activated."