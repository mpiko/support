#!/bin/bash
#-----------------------------------------
if [ $# -ne 1 ]
then
	echo Not enough args
	exit 1
fi

#-----------------------------------------
CLIENT=$1
MASTER=/opt/odoo-multi
SOURCE=$MASTER/clients/$CLIENT
DEST=/var/cydbackup/$CLIENT

DATE=$(date '+%Y%m%d-%H%M')

[ -d $DEST ] || mkdir -p $DEST

cd $SOURCE

pg_dump $CLIENT > $SOURCE/${CLIENT}.sql

tar zcvfp $DEST/${CLIENT}_${DATE}.tgz $SOURCE

#rm $SOURCE/${CLIENT}.sql

