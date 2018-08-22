#!/bin/bash
# get to current script base path
BASE_PATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_PATH_SCRIPT

# load configuration from external file
source backup.conf

# user apache2ctl to get the configuration for virtual hosts, containing path to each config file
# using grep, awk and sed to extract this path to a string
configFilesString=$(/usr/sbin/apache2ctl -S | grep "port 80 namevhost" | awk -F ' ' '{ print $5 }' | sed -E 's/[:()]//g' | sed -E 's/[ 0-9]$//g')

# explode this string to an array that can be looped through
configFiles=($(echo "$configFilesString" | tr ',' ' '))

# loop through every configfile
for configFile in "${configFiles[@]}"
do

        # if current config file is a file or a symbolic link, use it
        if [[ -f "$configFile" || -L "$configFile" ]]
        then

                # grep / search the config file for the location of the current virtual host's document root
                # thats the actual folder we want to backup 
                # put this into a string
                srcFolder=$(grep -oE 'DocumentRoot \"(.*)\"' $configFile | awk -F ' ' '{ print $2 }' | sed -E 's/["]//g')

                # if the current string has a length, provide this information to the actual backup script
                len=${#srcFolder}
                if [ "$len" -gt "0" ]
                then
                        # we also provide a destination folder, which is just the last part of the 
                        # document root, because we do not want to create the backup in e.g.
                        # /backup-location/var/www/sample/sub-domain but in
                        # /backup-location/sub-domain
                        ./backupFilesystem.sh -f $srcFolder -d "${BASE_PATH_BACKUP}htdocs/$(basename $srcFolder)"
                fi

        fi

done

unset BASE_PATH_SCRIPT
unset BASE_PATH_BACKUP
unset BASE_PATH_TEMP
unset LOG_FILE
unset PASSPHRASE
unset GPG_PUB_KEY
unset WEBDAV_USER
unset WEBDAV_PASSWORD
unset WEBDAV_URL
