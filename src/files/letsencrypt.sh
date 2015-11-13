#!/bin/bash

virtualenv /home/sanpi/.local/share/letsencrypt/

for site in $(find /etc/nginx/sites-enabled -type l)
do
    echo "- $site"
    vhost=$(grep 'server_name ' $site | tr -d ' ' | sed 's/server_name/-d /' | sed 's/;//')
    email=
    if [ -n "$vhost" ]
    then
        /home/sanpi/.local/share/letsencrypt/bin/letsencrypt certonly $vhost -c /etc/letsencrypt/config.cli.ini --renew-by-default --server https://acme-v01.api.letsencrypt.org/directory --email $email
    fi
done

service nginx reload
