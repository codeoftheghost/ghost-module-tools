#!/bin/bash

# Filename  : gmm.sh
# Author    : Ghost
# Date      : 2024-10-20
# Desc.     : Ghost Module Manager (gmm) adalah script untuk mengelolah module aplikasi yang digunakan pada distribusi privasi dan anonimitas "Ghost Secure Live System (GSLS)"
# Version   : 1.0
# License   : GNU General Public License GPLv3.

# bersihkan layar
clear

cat <<EOF
   
   ________  _____  ___    ______            __
  / ____/  |/  /  |/  /   /_  __/___  ____  / /
 / / __/ /|_/ / /|_/ /_____/ / / __ \/ __ \/ / 
/ /_/ / /  / / /  / /_____/ / / /_/ / /_/ / /  
\____/_/  /_/_/  /_/     /_/  \____/\____/_/  
      Ghost Module Manager Tool 1.0~beta

EOF

help() {
    echo ""
    echo "Usage:"
    echo "sudo gmm activate path/to/module.sb => to activate module"
    echo "sudo gmm deactivate module-name => to deactivate module"
    echo "sudo gmm add application-name => to add new application into new module"
    echo "sudo gmm help => to see how to use this tool"
    echo ""
    exit 1
}

wrongInput() {
    echo "Wrong input. For help, Use: sudo gmm help."
    echo ""
    exit 1
}

# Fungsi untuk mengaktifkan modul
activateModule() {
    MODULE_PATH=$1
    MODULE_NAME=$(basename "$MODULE_PATH")
    MOUNT_POINT="/mnt/$MODULE_NAME"
    
    if [ -z "$MODULE_PATH" ]; then
        echo "Error: Module path not given as parameter"
        echo "Usage: sudo gmm activate path/to/module.sb"
        echo ""
        wrongInput
    fi

    # Cek ekstensi modul
    if [[ "$MODULE_PATH" != *.sb ]]; then
        echo "Error: '$1' is not a .sb module"
        echo "Usage: sudo gmm activate path/to/module.sb"
        echo ""
        wrongInput
    fi

    # Buat direktori mount untuk modul
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi

    # Mount module dengan opsi read-only kedalam direktori mount
    echo "Mounting module $MODULE_NAME to $MOUNT_POINT"
    mount -o loop,ro "$MOUDLE_PATH" "$MOUNT_POINT"

    # Overlay hasil mount modul ke dalam root filesystem
    if [ ! -d "/union" ]; then
        mkdir /union
    fi

    mount -t overlay overlay -o lowerdir="$MOUNT_POINT", upperdir=/,workingdir=/union /

    # Dynamic linking dan update cache library
    echo "Updating library cache"
    ldconfig

    echo "Module $MODULE_NAME has been activated."
    echo ""
}

# Fungsi untuk menonaktifkan modul
deacivate() {
    MODULE_NAME=$1
    MOUNT_POINT="/mnt$MODULE_NAME"
    UNION_DIR="/union/$MODULE_NAME"

    if [ -z "$MODULE_NAME" ]; then
        echo "Error: Module name not given as parameter."
        echo "Usage: sudo gmm deactivate module-name"
        echo ""
        wrongInput
    fi

    # Cek apakah modul sudah ter-overlay
    if mount | grep -l "$UNION_DIR"; then
        echo "Deactivating module $MODULE_NAME"

        # Unmounting overlay module dari filesystem
        umount "$UNION_DIR"

        # Cek direktori mount point modul, apakah masih digunakan atau tidak.
        if mountpoint -q "$MOUNT_POINT"; then
            echo "Unmounting $MOUNT_POINT"

            #Unmount modul dari mount point-nya
            umount "$MOUNT_POINT"
        fi

        # Hapus direktori yang berhubungan dengan modul
        rm -rf "$MOUNT_POINT" "$UNION_DIR"

        # Dynamic linking dan update chache library
        echo "Updating library cache after deactivation module."
        ldconfig

        echo "Module $MODULE_NAME has been deactivate."
        echo ""
    else
        echo "Error: $MODULE_NAME module not found on this system."
        echo ""
        wrongInput
    fi
}

add() {
    APP_NAME=$1

    if [ -z "$APP_NAME" ]; then
        echo "Error: Application name not given as parameter."
        echo "Usage: sudo gmm add app-name"
        echo ""
        wrongInput
    fi

    # Cek apakah aplikasi terpasang beserta versinya
    if command -v "$APP_NAME" &> /dev/null; then
        APP_VERSION=$("$APP_NAME" --version 2>&1 | head -n 1)
        echo "$APP_NAME found with version: $APP_VERSION"
    else
        echo "Error: The $APP_NAME is not found or has not been installed. Check the $APP_NAME name or install it first, so that gmm tool can add it to module."
        echo ""
        wrongInput
    fi

    # Set variabel direktori aplikasi
    APP_PATH_MODULE="/tmp/ghost/module/$MODULE_NAME/"

    # Buat direktori utama module
    if [[ ! -d "$APP_PATH_MODULE" ]]; then
        mkdir -p "$APP_PATH_MODULE"
    fi

    # Buat list dari semua file aplikasi yang terinstal di sistem
    APP_FILE_LIST=$(rpm -ql "$APP_NAME")

    # Set IFS untuk memisahkan APP_FILE_LIST berdasarkan baris baru
    IFS=$'\n'

    # Perulangan untuk menyain file aplikasi ke direktori module
    for ITEM in $APP_FILE_LIST; do
        # melewatkan semua file di direktori .build-id
        if [[ "$ITEM" == /usr/lib/.build-id* ]]; then
            continue
        fi

        mkdir -p "$APP_PATH_MODULE$(dirname "$ITEM")"
        cp --parents -r "$ITEM" "$APP_PATH_MODULE"
    done

    # Kembalikan IFS ke default
    unset IFS

    echo "$APP_NAME successfully added to module."
    echo "Add other applications or generate modules with the 'create' command."
    echo ""
}

if [ -z "$1" ]; then
    wrongInput
fi

case "$1" in
    "activate")
        activateModule "$2"
        ;;
    "deactivate")
        deacivate "$2"
        ;;
    "add")
        add "$2"
        ;;
    "help")
        help
        ;;
    *)
        wrongInput
        ;;
esac