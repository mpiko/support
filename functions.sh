#!/bin/bash
# functions

#-----------------------------------------
write_scripts(){
    echo "sudo systemctl start odoo_${CLIENT}.service" > $WORK/service_start_${CLIENT}.sh
    echo "sudo systemctl stop odoo_${CLIENT}.service" > $WORK/service_stop_${CLIENT}.sh
    echo "sudo systemctl restart odoo_${CLIENT}.service" > $WORK/service_restart_${CLIENT}.sh
    chmod 755 $WORK/service_start_${CLIENT}.sh
    chmod 755 $WORK/service_stop_${CLIENT}.sh
    chmod 755 $WORK/service_restart_${CLIENT}.sh

    echo "added: $WORK/service_start_${CLIENT}.sh"
    echo "added: $WORK/service_stop_${CLIENT}.sh"
    echo "added: $WORK/service_restart_${CLIENT}.sh"

}

#-----------------------------------------
display_footer() {
# Display a footer:
echo "
The service for $CLIENT can be managed via:
 Start:
    sudo systemctl start odoo_${CLIENT}.service
 Stop:
    sudo systemctl stop odoo_${CLIENT}.service
 Restart:
    sudo systemctl restart odoo_${CLIENT}.service
 Status:
    sudo systemctl status odoo_${CLIENT}.service

Or start manually with:
    $WORK/start_${CLIENT}.sh

URL: http://${CLIENT}.$DOMAIN
"
}
#-----------------------------------------
