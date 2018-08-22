#!/bin/bash
# get to current script base path
# thanks to https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
BASE_PATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_PATH_SCRIPT

# load configuration from external file
source backup.conf

# this database does not need to be backuped, because it only contains several meta data, same for database "sys" and "performance_schema"
# see https://dev.mysql.com/doc/refman/5.5/en/information-schema.html
ignoreDatabases=['information_schema,sys,performance_schema']

# connect to mysql server (from connection details found in database.conf)
# and show all databases to put them into a string
databasesString=$(mysql --defaults-extra-file=database.conf -Bse 'show databases')
# as the upper line only returns a string, we need to explode it to an array
# thanks to Dennis Williamson @ https://stackoverflow.com/a/31405855/2360229
databasesArray=($(echo "$databasesString" | tr ',' ' '))

# loop through list of available databases
for database in "${databasesArray[@]}"
do
        # check if the current database is not part of the ignore-list
        if [[ ! " ${ignoreDatabases[*]} " == *"${database}"* ]]
        then
                # dump it's content to a file on the given path from backup.conf
                # mysqldump could return some error messages, that will be catched in "result"
                result="$( ( mysqldump --defaults-extra-file=database.conf ${database} > ${BASE_PATH_TEMP}${database}.sql ) 2>&1 )"

                len=${#result}

                # if result contains chars (aka an error message), send it to an email recipient
                if [ "$len" -gt "0" ]
                then
                        echo $result | mail -s "Error when dumping mysql database ${database}" $SUPERVISOR_EMAIL -r $LOCAL_EMAIL

                fi

                # call the actual backup script and give the path to the mysql dump
                ./backupFilesystem.sh -f ${BASE_PATH_TEMP}${database}.sql -d "${BASE_PATH_BACKUP}databases/${database}"

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
