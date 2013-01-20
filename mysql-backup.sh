#!/bin/bash
# Author:  Jason Barnett <J@sonBarnett.com>
# Written: Aug 20th, 2012

## README: ##
#############
## This script backs up all mysql databases into the directory of your choosing.
## It also rotates the backups and keeps the last 3 days of backups.
##
## This script assumes that you're running it as root and that the MySQL credentials being used are the localhost.



## VARIABLES ##
###############
# Email setting in case of a failure:
TO="user@domain.com"
SUBJECT="$(hostname -s) - MySQL Backup Failure"

# Backup routines?:
ROUTINES=false

# Backup desination directory:
DEST="/opt/dbbackups"

## Try to use pigz (multi-threaded gzip), or fallback and use gzip
GZIP=`which pigz`
[[ -z $GZIP ]] && { GZIP=`which gzip`; echo "INFO: You don't have pigz installed, using gzip instead."; echo "        This is not a big deal, pigz simply speeds up the backup process."; }

MYSQLDUMP=`which mysqldump`
[[ -z $MYSQLDUMP ]] && { echo "Unable to locate \"mysqldump\". Make sure it's in your PATH." 1>2; exit 1; }

MAIL=`which mutt`
[[ -z $MAIL ]] && MAIL=`which sendmail`


## MySQL credentials
mysql_user="username"
mysql_pass="password"



## Main Script ##
#################
# Check if mysql server even exists on the server.
[[ -x /usr/bin/mysqld_safe ]] || { echo "MySQL-Server is not installed on this machine."; exit 0; }

# Create destination if it does not exist.
[ ! -d $DEST ] && mkdir -p $DEST

# Only root can access it!
chown root:root -R $DEST
chmod 0750 $DEST

# Get all database list first
DBs="$(mysql -hlocalhost -u${mysql_user} -p${mysql_pass} -BNe 'show databases;' | egrep -v '^(information_schema)$')"
mysql_status=$?

## Setup ROUTINES variable if ROUTINES == true
[[ $ROUTINES == true ]] && ROUTINES="--routines" || ROUTINES=

backup_failed=
for db in $DBs;do
    FILE="$DEST/$db.sql.gz"
    [ -f $FILE.2 ] && rm -f $FILE.2
    [ -f $FILE.1 ] && mv $FILE.1 $FILE.2
    [ -f $FILE.0 ] && mv $FILE.0 $FILE.1
    [ -f $FILE ] && mv $FILE $FILE.0
    echo -n "Backing up $db... "
    $MYSQLDUMP -u${mysql_user} -p${mysql_pass} -hlocalhost $ROUTINES -B $db | $GZIP -9 > $FILE
    if [[ $? == "0" ]];
        then
            echo Success!
        else
            echo Failed!
            backup_failed=true
            failed_dbs="$db $failed_dbs"
    fi
done


if [[ $mysql_status == "1" ]];then
    echo "There was an issue grabbing a complete list of databases to backup." | mutt -s "$SUBJECT" $TO
elif [[ $backup_failed == "true" ]];then
    echo "There was an issue backing up the following databases: ${failed_dbs}" | mutt -s "$SUBJECT" $TO
fi
