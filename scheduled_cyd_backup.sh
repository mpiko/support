#!/bin/bash
#
# Everythng not backed up here can be recreated from source.
#
# Directory Structure
# /opt/odoo-multi/bin            ** Backed up here
# /opt/odoo-multi/clients        Backed up individually
# /opt/odoo-multi/env15          Static and created during install 
# /opt/odoo-multi/odoo           Static and created during install
# /opt/odoo-multi/tpa            Static - downloaded as desired.
# /opt/odoo-multi/tpa/approved
# /opt/odoo-multi/tpa/blacklist
# /opt/odoo-multi/tpa/testing
# /opt/odoo-multi/tpa/zips


BACKUPHOME=/var/cydbackup 

#-----------------------------------------
# delete backups older than 10 days.
find $BACKUPHOME -mtime 10 -name '*.tgz' -exec rm {} \;  2> /dev/null

#-----------------------------------------
# Backup scripts
SOURCE=/opt/odoo-multi/bin
DEST=$BACKUPHOME/odoo-multi

DATE=$(date '+%Y%m%d-%H%M')

[ -d $DEST ] || mkdir -p $DEST

tar zcvf $DEST/odoo-multi_bin-${DATE}.tgz $SOURCE

#-----------------------------------------
# backup each client along with its data dump 
for CLIENT in $(ls -1 /opt/odoo-multi/clients)
do
    #echo $CLIENT
    /opt/odoo-multi/bin/backupClient.sh $CLIENT > /dev/null #/opt/odoo-multi/${CLIENT}.log
done

#-----------------------------------------
# Remove directories which have no content.
for DIR in $(ls -1 $BACKUPHOME)
do
    SIZE=$(ls -1 $BACKUPHOME/$DIR | wc -l | gawk '{print $1}')
    if [ $SIZE -eq 0 ]
    then
        echo Removing stale $BACKUPHOME/$DIR
        rm -r $BACKUPHOME/$DIR
    fi
done

