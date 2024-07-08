#!/bin/sh

# This script assumes that variables are set:
# BORG_REPO
# BORG_PASSCOMMAND
# dest_name
# archive_name
# create_opts
# dirs_to_backup
# keep_policy
# exclude

. $config_dir/borg_environ
. $dest

### Action ###

info "Creating backup to: $dest_name"

borg create                                     \
    --show-rc                                   \
    $create_opts                                \
    ::"$archive_name-{utcnow:%Y-%m-%d_%H:%M}"   \
    $dirs_to_backup                             \
    $exclude

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# # archives of THIS machine. The '{hostname}-*' matching is very important to
# # limit prune's operation to this machine's archives and not apply to
# # other machines' archives also:
#
borg prune                             \
    --list                             \
    --glob-archives "$archive_name-*"  \
    --show-rc                          \
    $keep_policy

prune_exit=$?

# actually free repo disk space by compacting segments
#
info "Compacting repository"

borg compact

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}
