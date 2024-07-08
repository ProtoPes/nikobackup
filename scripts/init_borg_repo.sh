#!/bin/sh

config_dir="$HOME/.config/backup"
. $config_dir/borg_environ
. $config_dir/backup_env_google_drive

borg init --encryption=repokey-blake2
