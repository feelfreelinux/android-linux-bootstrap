#!/system/bin/sh
# Minimal proot run script

BASE_DIR="$PWD"

export PROOT_TMP_DIR="$BASE_DIR/tmp"
export PROOT_L2S_DIR="$BASE_DIR/bootstrap/.proot.meta"

mkdir -p "$PROOT_TMP_DIR"
mkdir -p "$PROOT_L2S_DIR"

PATH='/sbin:/usr/sbin:/bin:/usr/bin'
USER='root'
HOME='/root'
unset TMPDIR
unset LD_LIBRARY_PATH
export PATH
export USER
export HOME
./root/bin/proot -r bootstrap -b /dev -b /proc -b /sys -b /system -b /vendor -b /storage --link2symlink -p -L -w /root /bin/sh -l
