#!/bin/bash

# Incremental Backup Script using tar.
# Date: 21th of march - 2013
# By 0T3B
# Reviewed by s1lv4

DIR_BKP="/root /usr/local/sbin /usr/local/bin /etc /var/www"
DEST=/backup/FS/`hostname`
DAY_DIR=`date +%A`
DEST_DIR=${DEST}/${DAY_DIR}
DATE=`date +%F-%H%M`
TAR=`which tar`
INC_FILE="${DEST}/inc"
FILE_NAME=backup-`date +%F.tar`
TAR_OPT="cvpf ${DEST_DIR}/${FILE_NAME} --one-file-system --listed-incremental $INC_FILE $DIR_BKP"
LOG="${DEST_DIR}/${DATE}.log"
LOG_ERR="${DEST_DIR}/${DATE}.err"
HOUR=`date +%-R`

_autofs_opt()
{
     case $INPUT in
          y|Y)
               AUTOFS=/etc/init.d/autofs
               if [ -x $AUTOFS ] ; then
                    $AUTOFS stop; $AUTOFS start
               else
                    echo -e "Script $AUTOFS didn't find."
                    echo -e "Please, note that autofs must be configured to this script work property."
                    echo -e "If autofs is OK, then restart autofs manually and verify if $DEST is right mounted."
                    echo -e "Exiting script. By!"
                    exit 1
               fi
               ;;
          n|N)
               echo -e "Exiting script. By!"
               exit 1
               ;;
          *)
               echo -e "Type \"Y\" to restart autofs automatically or \"N\" to exit the script."
               ;;
     esac
}

_check_dirs()
{
     if [ ! -d $DEST ] ; then
          mkdir -p $DEST
          echo -e "Directory $DEST_DIR created." >> ${LOG}
     fi

     if [ ! -d ${DEST_DIR} ] ; then
          mkdir -p ${DEST_DIR}
          echo -e "Directory ${DEST_DIR} created." >> ${LOG}
     fi
}

_check_mount()
{
     cat /proc/mounts | grep -i /backup
     if [ ! `echo $?` == 0 ] ; then
          echo -e "Destination isn't mounted. Please, verify autofs."
          echo -e "Do you want that script restart autofs daemon? (Type \"Y\" to YES or \"N\" to NO.)"
          echo -e "Waiting for 5 seconds....."
          sleep 1

          while [ $INPUT -z ] ;do
               read INPUT
               SEC=4
               echo -e "Waiting for $SEC seconds...."
               sleep 1

               if [ $SEC == 0 ] ; then
                    exit 1
               fi
          done; 
          
          _autofs_opt
     fi
}

_backup()
{
     echo -e "Backup starting at $HOUR..." >> $LOG
     $TAR $TAR_OPT >> ${LOG} 2>> $LOG_ERR
     echo -e "Backup finished at $HOUR..." >> $LOG
}

_check_mount
_check_dirs
_backup
