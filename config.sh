#!/bin/bash

CLIENT=$1

#-----------------------------------------
#
ME=$(hostname)

if [ $ME = "ocean" ]
then
    DOMAIN=wombat.local
    CYDUSER=michael
    CYDGROUP=michael
    SSL=no
elif [ $ME = "Common" ]
then
    DOMAIN=cyder.com.au
    CYDGROUP=support
    CYDUSER=support
    SSL=yes
else
    echo "not sure where I am"
    exit 1
fi


#-----------------------------------------
#
LANG=en_AU

#-----------------------------------------
#
MASTER=/opt/odoo-multi
CLIENTS=$MASTER/clients
WORK=$CLIENTS/$CLIENT
DATA=$WORK/data
CONF=${CLIENT}.conf

#-----------------------------------------
#
# Modules
#MODULES="contacts,sale_management,mrp,stock,purchase,crm,project,repair,maintenance,survey,hr_attendance,hr,fleet,calendar,note"
MODULES="l10n_au,base_automation,contacts,sale_management,mrp,stock,purchase,crm,project,fleet"
MODULES="l10n_au,base_automation"
PORTFILE=$MASTER/.port

#-----------------------------------------
#
# Addons
CLIENT_ADDONS=$WORK/${CLIENT}_addons
APPROVED_ADDONS=$MASTER/tpa/approved
TEST_ADDONS=$MASTER/tpa/testing

#-----------------------------------------
#
# functions
getdate() {
    echo $(date '+%Y%m%d-%H%M')
}
