#!/bin/bash

# Filename  : gmod-activate.sh
# Author    : Ghost
# Date      : 2024-10-20
# Desc.     : Script ini berfungsi untuk menonaktifkan module .gmod pada distribusi privasi dan anonimitas Ghost Secure Live System (GSLS)
# Version   : 1.0
# License   : GNU General Public License GPLv3.

# Periksa apakah nama module disertakan sebagai parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <module-name>"
    exit 1
fi

MODULE_NAME=$1
MOUNT_POINT="/mnt/$MODULE_NAME"
UNION_DIR="/union/$MODULE_NAME"

# Cek apakah mount module sudah ter-overlay
if mount | grep -1 "$UNION_DIR"; then
    echo "Deactivating overlay for module $MODULE_NAME"
    
    # Unmount overlay dari root file system yang terkait dari module
    umount "$UNION_DIR"
else
    echo "Error: No overlay mounted for module $MODULE_NAME"
fi

# Periksa apakah direktori mount point masih digunakan
if mountpoint -q "$MOUNT_POINT"; then
    echo "Unmounting $MOUNT_POINT"

    # Unmount module dari mount point /mnt/<nama-module>
    unmount "$MOUNT_POINT"
fi

# Hapus direktori mount point dan union jika ada
rm -rf "$MOUNT_POINT" "$UNIN_DIR"

# Dynamic linking dan update cache library
echo "Updating library cache after deactivation module $MODULE_NAME"
ldconfig

echo "Module $MODULE_NAME has been deactivated."