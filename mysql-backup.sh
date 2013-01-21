#!/bin/bash
# Author: Jason Barnett <J@sonBarnett.com>
MYSQL_BACKUP_VERSION=1.0

HOME=/root

# Check if mysql server even exists on the machine and exit if it's not.
[[ -x /usr/bin/mysqld_safe ]] || { echo "MySQL-Server is not installed on this machine."; exit 0; }

function ask_question {
    question=$1
    read -p "$question: "
    echo $REPLY
}

function ask_yes_no {
    question=$1
    read -p "$question: [y/n] "
    local answer=$(echo $REPLY | tr '[:upper:]' '[:lower:]')

    while [[ "${answer}" != "yes" && "${answer}" != "no" && "${answer}" != "y" && "${answer}" != "n" ]];do
        read -p "y/n only please... $question: [y/n] "
        answer=$(echo $REPLY | tr '[:upper:]' '[:lower:]')
    done

    [[ "${answer}" == "yes" || "${answer}" == "y" ]] && echo true || echo false
}

function msg {
    echo $1
}

function err_msg {
    echo $1 1>&2
}

function fail_msg {
    echo $1 1>&2
    exit 1
}

function get_mysql_credentials {
    MYSQL_USER=$(ask_question "MySQL Username")
    [[ -z $MYSQL_USER ]] && exit 1
    MYSQL_HOST=$(ask_question "MySQL Host")
    MYSQL_PASS=$(ask_question "MySQL Password")
    [[ -n ${MYSQL_USER} && -n ${MYSQL_HOST} && -n ${MYSQL_PASS} ]] || {
        fail_msg "You have not specified a MySQL Username, Host and/or Password"
    }

    check_mysql_credentials
    mkdir -p ${HOME}/.config/mysql-backup
    chmod 700 ${HOME}/.config/mysql-backup
    echo "MYSQL_USER=${MYSQL_USER}" > ${HOME}/.config/mysql-backup/config
    echo "MYSQL_HOST=${MYSQL_HOST}" >> ${HOME}/.config/mysql-backup/config
    echo "MYSQL_PASS=${MYSQL_PASS}" >> ${HOME}/.config/mysql-backup/config
    chmod 600 ${HOME}/.config/mysql-backup/config
}

function check_mysql_credentials {
    temp_file=$(mktemp /tmp/.mysql-backup.XXXXXX)
    local good_credentials=

    mysql -u${MYSQL_USER} -h${MYSQL_HOST} -p${MYSQL_PASS} \
        -BNe 'show databases;' &> ${temp_file} && good_credentials=true

    if [[ -z $good_credentials ]];then
        fail_msg "You have a bad MySQL Username, Host and/or Password"
    fi

    rm -f ${temp_file}
}

function mysql_routines_check {
   [[ -z $ROUTINES ]] && ROUTINES=$(ask_yes_no "Dump stored routines?")
   [[ ${ROUTINES} == "true" ]] && ROUTINES='--routines' || ROUTINES=
}

function choose_backup_destination {
    echo "I need to write this..."
}


## MAIN SCRIPT ##
#################
# Check if mysql server even exists on the machine and exit if it's not.
[[ -x /usr/bin/mysqld_safe ]] || { echo "MySQL-Server is not installed on this machine."; exit 0; }

# Load config file:
[[ -e ${HOME}/.config/mysql-backup/config ]] && . ${HOME}/.config/mysql-backup/config

[[ -n ${MYSQL_USER} && -n ${MYSQL_HOST} && -n ${MYSQL_PASS} ]] && check_mysql_credentials || get_mysql_credentials

# Backup desination directory, soon to replace with function later...
DEST="/opt/dbbackups"

## Try to use pigz (multi-threaded gzip), or fallback and use gzip
GZIP=`which pigz`
[[ -z $GZIP ]] && { GZIP=`which gzip`; msg "INFO: You don't have pigz installed, using gzip instead."; msg "        This is not a big deal, pigz simply speeds up the backup process."; }

MYSQLDUMP=`which mysqldump`
[[ -z $MYSQLDUMP ]] && { err_msg "Unable to locate \"mysqldump\". Make sure it's in your \$PATH."; exit 1; }

MAIL=`which mutt`
[[ -z $MAIL ]] && MAIL=`which mail`
[[ -z $MAIL ]] && err_msg "Couldn't find mutt or mail. Therefore we cannot send an email if the backup fails."


# Create destination if it does not exist.
[ ! -d $DEST ] && mkdir -p $DEST

# Only root can access it!
chown root:root -R $DEST
chmod 0750 $DEST

# Get all database list first
DBs="$(mysql -u${MYSQL_USER} -h${MYSQL_HOST} -p${MYSQL_PASS} -BNe 'show databases;' | egrep -v '^(information_schema)$')"
mysql_status=$?

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


if [[ $mysql_status != "0" ]];then
    fail_msg "There was an issue grabbing a complete list of databases to backup."
elif [[ $backup_failed == "true" ]];then
    fail_msg "There was an issue backing up the following databases: ${failed_dbs}"
fi
