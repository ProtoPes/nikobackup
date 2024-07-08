#!/bin/sh

# This script will mount remote storage, create archive with current
# date using borgbackup

# Make file descriptors of stdout and stderr a file
# If using sh better not to use "&>"
exec >>'/var/log/backup.log'
exec 2>>'/var/log/backup_errors.log'

### Variables ###

export config_dir="$HOME/.config/backup"

### FUNCTIONS ###

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" ; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

error() {
    info $* >&2
}

abort() {
    # Log to stderr and exit with failure.
    error $*
    exit 1
}

[ ! -d "$config_dir" ] && abort "Config dir not found! Abort..."
[ ! -f "$config_dir/borg_environ" ] && abort "borg_environ not found! Abort..."

# How many destinations we have
destinations=$(find $config_dir -type f -name "backup_env*")

[ $(echo $destinations | wc -w) -eq 0 ] && abort "backup_env not found, provide at least one! Abort..."

export -f info

# Notify user about Backup process
info "Backup job started"

### Actual backup process ###

for dest in $destinations ; do
    export dest
    mount_helper.sh -m
    [ $? != 0 ] && error "Mount failed, skipping $dest" && continue
    do_backup.sh
    [ $? != 0 ] && error "Backup errors encountered with $dest"
    mount_helper.sh -u
    unset dest
done

info "Backup job finished"
