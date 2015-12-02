#!/bin/bash

letsencrypt_root="/home/sanpi/.local/share/letsencrypt"

get_vhosts()
{
    site=$1

    vhosts=$(grep 'server_name ' $site | tr -d ' ' | sed 's/server_name//' | sed 's/;//')
    vhosts=($vhosts)

    echo ${vhosts[*]}
}

count_char()
{
    str=$1
    char=$2

    echo "$str" | grep -oF "$char" | wc -l
}

get_main_vhost()
{
    vhosts=$1

    nb_dot=$(count_char $vhosts '.')
    if [ $nb_dot -gt 1 ]
    then

        main_vhost=$(echo ${vhosts[0]} | cut -d . -f $nb_dot-)
    else
        main_vhost=${vhosts[0]}
    fi

    echo $main_vhost
}

get_email()
{
    vhosts=$1

    main_vhost=$(get_main_vhost $vhosts)
    email="postmaster@$main_vhost"

    echo $email
}

transform_vhost_to_arg()
{
    vhosts=$1

    vhosts_arg=''
    for vhost in ${vhosts[@]}
    do
        vhosts_arg="$vhosts_arg -d $vhost"
    done

    echo $vhosts_arg
}

if [ $# -gt 0 ]
then
    sites=$@
else
    sites=$(find /etc/nginx/sites-enabled -type l)
fi

status='skip'

virtualenv "$letsencrypt_root"

for site in $sites
do
    echo -n "$site: "

    vhosts=$(get_vhosts $site)

    if [ -n "$vhosts" ]
    then
        email=$(get_email $vhosts)

        vhosts_arg=$(transform_vhost_to_arg "$vhosts")

        "$letsencrypt_root/bin/letsencrypt" certonly $vhosts_arg \
            --email "$email" -c /etc/letsencrypt/config.cli.ini \
            --renew-by-default \
            --server https://acme-v01.api.letsencrypt.org/directory
        status=$?

        if [ "$status" -eq 0 ]
        then
            status='pass'
        else
            status='fail'
        fi
    fi

    echo "$status"
done

service nginx reload
