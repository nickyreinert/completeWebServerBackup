#!/bin/bash
# get to current script base path
BASE_PATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_PATH_SCRIPT

# load configuration from external file
source backup.conf

# get current date and time for logging purposes
currentDate=$(date +"%Y-%m-%d")
currentTime=$(date +"%T")

# read command line parameters and assign them to source folder and destination folder variables
while getopts ":f:d:" opt; do
  case $opt in
    f) srcFolder=${OPTARG};;
    d) dstFolder=${OPTARG};;
  esac
done

# if no source folder is defined, exit the script
if [ -z ${srcFolder+x} ]
then
        echo "Define a folder or file to backup, usage: -f FILE_OR_FOLDER_TO_BACKUP [-d DESTINATION_FOLDER]"
        exit -1
else

        # if destination folder is not defined, use the source folder to 
        # define it
        if [ -z ${dstFolder+x} ]
        then
                dstFolder=${BASE_PATH_BACKUP}${srcFolder}
        fi

        # create log entry
        echo "${currentDate} ${currentTime} Creating backup of: ${srcFolder} destination: ${BASE_PATH_BACKUP}" >> ${BASE_PATH}${LOG_FILE}

        # if destination folder does not exist, create it
        if [ ! -d "$dstFolder" ]
        then
                mkdir -p $dstFolder

        fi

        # first use duplicity to create backup and put it to local file system
        duplicity --full-if-older-than 1M --encrypt-key $GPG_PUB_KEY $srcFolder file://$dstFolder --no-print-statistics --verbosity=$DUPLICITY_VERBOSITY
        duplicity remove-older-than 12M --encrypt-key $GPG_PUB_KEY --force file://$dstFolder --no-print-statistics --verbosity=$DUPLICITY_VERBOSITY
        duplicity remove-all-inc-of-but-n-full 1 --encrypt-key $GPG_PUB_KEY --force file://$dstFolder --no-print-statistics --verbosity=$DUPLICITY_VERBOSITY

        # second use duplicity to create backup and put it to remote destination, in this case webdav folder
        duplicity --full-if-older-than 1M --encrypt-key $GPG_PUB_KEY $srcFolder webdavs://$WEBDAV_USER:$WEBDAV_PASSWORD@$WEBDAV_URL/$dstFolder --no-print-statistics --ssl-no-check-certificate --verbosity=$DUPLICITY_VERBOSITY
        duplicity remove-older-than 12M --encrypt-key $GPG_PUB_KEY --force  webdavs://$WEBDAV_USER:$WEBDAV_PASSWORD@$WEBDAV_URL/$dstFolder --no-print-statistics --ssl-no-check-certificate --verbosity=$DUPLICITY_VERBOSITY
        duplicity remove-all-inc-of-but-n-full 1 --encrypt-key $GPG_PUB_KEY --force  webdavs://$WEBDAV_USER:$WEBDAV_PASSWORD@$WEBDAV_URL/$dstFolder --no-print-statistics --ssl-no-check-certificate --verbosity=$DUPLICITY_VERBOSITY

fi

unset BASE_PATH_SCRIPT
unset BASE_PATH_BACKUP
unset BASE_PATH_TEMP
unset LOG_FILE
unset PASSPHRASE
unset GPG_PUB_KEY
unset WEBDAV_USER
unset WEBDAV_PASSWORD
unset WEBDAV_URL
