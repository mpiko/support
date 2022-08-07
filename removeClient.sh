#!/bin/bash

if [ $# -ne 1 ] 
then
    echo Not enough args
    exit 1
fi

#-----------------------------------------
PATH=/opt/odoo-multi/bin:$PATH
. config.sh
unset LANG
#CLIENT=$1
#DOMAIN=cyder.com.au
#CYDUSER=support
#CYDGROUP=support
#LANG=en_AU
#MASTER=/opt/odoo-multi
#CLIENTS=$MASTER/clients/
#WORK=$CLIENTS/$CLIENT
#DATA=$WORK/data
#APPROVED_ADDONS=$MASTER/tpa/approved
#CONF=${CLIENT}.conf
#CLIENT_ADDONS=$WORK/${CLIENT}_addons
#MODULES="l10n_au,contacts,sale_management,mrp,stock,purchase,crm,project,fleet"
#PORTFILE=$MASTER/.port

if ! [ -d $WORK ]
then
    echo Cannot find $WORK. Exiting...
    exit 1
fi


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
    #sudo certbot delete --cert-name ${CLIENT}.$DOMAIN
    sudo rm -rf $WORK
    sudo rm /etc/nginx/sites-{enabled,available}/${CLIENT}.conf
    sudo systemctl reload nginx
else
    echo "Warning: Service removed but could not drop database."
    exit 4
fi
