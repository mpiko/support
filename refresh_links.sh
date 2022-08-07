#!/bin/bash

APPROVED_ADDONS=/opt/odoo-multi/tpa/approved
BASE=/opt/odoo-multi/clients
for CLIENT in $(ls -1 $BASE)
do
    # set the addon to this particular client.
    CLIENT_ADDONS=${BASE}/${CLIENT}/${CLIENT}_addons

    # Remove any broken links
    find $CLIENT_ADDONS -xtype l -exec rm {} \;

    # if the client does not have the addon, then link it in.
    for DIR in $(ls -1 $APPROVED_ADDONS)
    do
        if ! [ -e $CLIENT_ADDONS/$DIR ]
        then
            ln -s $APPROVED_ADDONS/$DIR $CLIENT_ADDONS/$DIR
        fi
    done
done
