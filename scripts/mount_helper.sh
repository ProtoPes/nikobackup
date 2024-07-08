#!/bin/sh

. "$dest"

mount_fun() {
    mkdir $mount_dir
    # Mount destination depending on fstab and variables
    mount $mount_dir \
        $mount_opts
    # Check drive
    [ -f "$BORG_REPO/config" ] || \
        ( echo "Repo not found" >&2 && rmdir $mount_dir && exit 1 )
}

umount_fun() {
    umount $mount_dir
    rmdir $mount_dir
}

case $1 in
    '-m') mount_fun ;;
    '-u') umount_fun ;;
    *) echo "only -m or -u otpions are allowed" >&2 && exit 1 ;;
esac
