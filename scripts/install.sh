#!/bin/sh

echo 'This script will configure borg backup on your machine.'

# Set config dir and backup places
# TODO: change backup_test
config_dir="$HOME/.config/backup_test"
env_dir='../templates/env'

[ ! -d $config_dir ] && mkdir -p $config_dir

cp "$env_dir/borg_environ" $config_dir/

while [[ ! -d $dirs_to_backup ]]; do
    echo 'Provide directory to backup'
    read dirs_to_backup
    [ ! -d $dirs_to_backup ] && echo 'Directory not found! Try again.'
done

sed -i "/dirs_to_backup=/ s:\$:\"$dirs_to_backup\":" \
    "$config_dir/borg_environ"

declare -a variables
declare -A values

variables=$(sed -n '/=$/s/=//p' $env_dir/backup_env_example)

echo
for line in $variables ; do
    echo $(sed -n "/^$line/{x;p;d;}; x" $env_dir/backup_env_example)
    echo -n "$line="
    read answer
    values[$line]=$answer
done

echo ${!values[*]}


env_filename=$config_dir/backup_env_${values['dest_name']}

cp -i "$env_dir/backup_env_example" $env_filename

for line in $variables ; do
    sed -i "/^$line/s:\$:'${values[$line]}':" $env_filename
done


# create_backup_env() {
#     while [ $answer != 'y' ]; do
#
#     done
#
# }
#
#
