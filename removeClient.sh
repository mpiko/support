#!/bin/bash

if [ $# -lt 1 ] 
then
    echo Not enough args
    exit 1
fi

#-----------------------------------------
PATH=/opt/odoo-multi/bin:$PATH
. config.sh
unset LANG

if ! [ -d $WORK ]
then
    echo Cannot find $WORK. Exiting...
    exit 1
fi

for OPT in $@
do
    if [ $OPT = "-y" ]
    then
        RESP=Y
    fi
done

while [ -z "$RESP" ]
do
    echo -n "You are about to complete remove $CLIENT. Are you sure?? (Y/n)"
    read RESP
    [ -z "$RESP" ] && continue
    if [ "$RESP" == "Y" ] || [ "$RESP" == "y" ]
    then
        echo "OK. Continuing"
    else
        echo "Aborting..."
        exit 2
    fi
done


#-----------------------------------------
sudo systemctl stop odoo_${CLIENT}
if [ $? -ne 0 ]
then
    echo "could not stop odoo_${CLIENT}"
    exit 3
fi
sudo systemctl disable odoo_${CLIENT} > /dev/null
sudo systemctl daemon-reload > /dev/null
sudo systemctl reset-failed > /dev/null

dropdb $CLIENT
if [ $? -eq 0 ]
then
    if grep ssl_certificate_key /etc/nginx/sites-available/${CLIENT}.conf  > /dev/null
    then
        sudo certbot delete --cert-name ${CLIENT}.$DOMAIN
    fi
    sudo rm -rf $WORK
    sudo rm /etc/nginx/sites-{enabled,available}/${CLIENT}.conf
    sudo systemctl reload nginx
else
    echo "Warning: Service removed but could not drop database."
    exit 4
fi
