#!/bin/bash
# get to current script base path
# thanks to https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
BASE_PATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_PATH_SCRIPT

# load configuration from external file
source backup.conf

# user apache2ctl to get the configuration for virtual hosts, containing path to each config file
# using grep, awk and sed to extract this path to a string
configFilesString=$(/usr/sbin/apache2ctl -S | grep "port 80 namevhost" | awk -F ' ' '{ print $5 }' | sed -E 's/[:()]//g' | sed -E 's/[ 0-9]$//g')

# explode this string to an array that can be looped through
# thanks to Dennis Williamson @ https://stackoverflow.com/a/31405855/2360229
configFiles=($(echo "$configFilesString" | tr ',' ' '))

# loop through every configfile
for configFile in "${configFiles[@]}"
do


        if [[ -f "$configFile" || -L "$configFile" ]]
        then

                srcFolder=$(grep -oE 'DocumentRoot \"(.*)\"' $configFile | awk -F ' ' '{ print $2 }' | sed -E 's/["]//g')

                len=${#srcFolder}

                if [ "$len" -gt "0" ]
                then
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
