#!/bin/bash

# Michael Piko
# michael@cyder.com.au
#
# TODO
# - add a dynamic list of modules to install
# - add a lookup to confirm cname pointing to
#   common.cyder.com.au exists
# 
#-----------------------------------------
if [ $# -lt 1 ]
then
	echo Not enough args
	exit 1
fi

#-----------------------------------------
PATH=/opt/odoo-multi/bin:$PATH
. config.sh
. functions.sh

ENTERPRISE=""
DEMO="--without-demo=all"
for OPT in $@
do
    if [ $OPT = "-e" ]
    then
        ENTERPRISE=",./odoo/enterprise"
    elif [ $OPT = "-d" ]
    then
        DEMO=""
        DEMODATA=True
    fi
done
ADDONS="$CLIENT_ADDONS,./odoo/addons$ENTERPRISE" 

MODULES="l10n_au,contacts"

#-----------------------------------------
if [ -d $WORK ]
then
    echo $CLIENT already exists. exiting...
    exit 2
fi

#-----------------------------------------
cd $MASTER

# look for an availiable port
PORT=$(findFreePort)
LPORT=$(($PORT + 1))


#-----------------------------------------
echo "Setup:
CLIENT=$1
DOMAIN=$DOMAIN
LANG=$LANG
MASTER=$MASTER
WORK=$MASTER/$CLIENT
DEMODATA=$DEMODATA
CONF=${CLIENT}.conf
ADDONS=$ADDONS
MODULES=$MODULES
PORT=$PORT
lONGPOLLINGPORT=$LPORT
"
#-----------------------------------------
# Set up Addons directory
echo "Creating directory $CLIENT_ADDONS"
mkdir -p $CLIENT_ADDONS $DATA
./env15/bin/odoo scaffold $CLIENT_ADDONS/${CLIENT}_base

# install approved addons
for DIR in $(ls -1 $APPROVED_ADDONS)
do
    ln -s $APPROVED_ADDONS/$DIR $CLIENT_ADDONS/$DIR
done


# Set up the log directory
echo "creating log directory: $WORK/log"
mkdir -p $WORK/log

# set up the data directory
echo "Creating data directory: $DATA"
mkdir -p $DATA

#-----------------------------------------
#build the database and config
echo "Building Odoo database"
./env15/bin/odoo -d $CLIENT -c $WORK/$CONF --addons-path="$ADDONS" -i $MODULES $DEMO -p $PORT --logfile=$WORK/log/${CLIENT}.log --longpolling-port=$LPORT -D $DATA --db-filter=$CLIENT --load-language=$LANG --http-interface=localhost --save --stop

sed -i.bak 's/admin_passwd = admin/admin_passwd = $pbkdf2-sha512$25000$01oLwTiHsDbmHCOE0Lo3xg$qvVi3bgjunp5MINYkGe1PdoC9nMzwrlgDCwvt4RerPGN6PtXSQHSeiDhiRiFxBk4kjZwPiOYK6Lh2xGwBRQCxg/' $WORK/$CONF 

#-----------------------------------------
# Set up a nginx virtual host for this client
sudo su -c "cat > /etc/nginx/sites-available/${CLIENT}.conf<<EOM
server {
    listen 80; 
    listen [::]:80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name $CLIENT.$DOMAIN; 
        location / { 
            proxy_pass http://localhost:$PORT;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \\\$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \\\$host;
            proxy_cache_bypass \\\$http_upgrade;
            client_max_body_size 64M;
        }

}
EOM"

sudo ln -s /etc/nginx/sites-{available,enabled}/${CLIENT}.conf 
sudo systemctl reload nginx

#-----------------------------------------
# Create a startup script
cat >$WORK/start_${CLIENT}.sh<<EOL
#!/bin/bash

CLIENT=$CLIENT
MASTER=$MASTER
WORK=$WORK
CONF=$CONF
CLIENT_ADDONS=$WORK/${CLIENT}_addons

\$MASTER/env15/bin/odoo -c \$WORK/\$CONF \$@
EOL

chmod 755 $WORK/start_${CLIENT}.sh

#-----------------------------------------
# Create a service for this client
sudo su -c "cat > /lib/systemd/system/odoo_${CLIENT}.service<<EOM
[Unit]
Description=Oddo service for $CLIENT
After=network.target

[Service]
Type=simple
User=$CYDUSER
Group=$CYDGROUP
ExecStart=/opt/odoo-multi/clients/$CLIENT/start_${CLIENT}.sh
KillMode=mixed

[Install]
WantedBy=multi-user.target

EOM"

sudo systemctl enable odoo_${CLIENT}.service
sudo systemctl start odoo_${CLIENT}.service

#-----------------------------------------

# Set up ssl
if [ $SSL = "yes" ]
then
    sudo certbot --nginx -d ${CLIENT}.${DOMAIN} --non-interactive --agree-tos --redirect -m ${CYDUSER}\@${DOMAIN}
fi

#-----------------------------------------
write_scripts
display_footer

# Display a footer:
#echo "
#The service for $CLIENT can be managed via:
#    sudo systemctl [start|stop|status] odoo_${CLIENT}.service
#Or start manually with:
#    $WORK/start_${CLIENT}.sh
#"


#-----------------------------------------

