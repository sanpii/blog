#!/bin/bash

readonly LETSENCRYPT_ROOT="/home/sanpi/.local/share/letsencrypt"
readonly CERT_MAX_AGE=60

get_vhosts()
{
    local site=$1
    local vhosts

    vhosts=$(grep 'server_name ' $site | tr -d ' ' | sed 's/server_name//' | sed 's/;//' | grep -v '.onion$')
    vhosts=($vhosts)

    echo ${vhosts[*]}
}

count_char()
{
    local str=$1
    local char=$2

    echo "$str" | grep -oF "$char" | wc -l
}

get_main_vhost()
{
    local vhosts=$1
    local nb_dot
    local main_vhost

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
    local vhosts=$1
    local main_vhost
    local email

    main_vhost=$(get_main_vhost $vhosts)
    email="postmaster@$main_vhost"

    echo $email
}

get_lastchange()
{
    local vhosts=$1
    local pem="/etc/letsencrypt/live/${vhosts[0]}/fullchain.pem"
    local lastchange=-1

    if [ -e $pem ]
    then
        lastchange=$(expr $(expr $(date +%s) - $(date +%s -r $pem)) / 86400)
    fi

    echo $lastchange
}

transform_vhost_to_arg()
{
    local vhosts=$1
    local vhost
    local vhosts_arg=''

    for vhost in ${vhosts[@]}
    do
        vhosts_arg="$vhosts_arg -d $vhost"
    done

    echo $vhosts_arg
}

main()
{
    if [ $# -gt 0 ]
    then
        local sites=$@
    else
        local sites=$(find /etc/nginx/sites-enabled -type l)
    fi


    virtualenv "$LETSENCRYPT_ROOT"

    for site in $sites
    do
        local status='skip'

        echo -n "$site: "

        local vhosts=$(get_vhosts $site)

        if [ -n "$vhosts" ]
        then
            local email=$(get_email $vhosts)
            local vhosts_arg=$(transform_vhost_to_arg "$vhosts")
            local lastchange=$(get_lastchange $vhosts)

            if [ $lastchange -lt 0 || $lastchange -gt $CERT_MAX_AGE ]
            then
                "$LETSENCRYPT_ROOT/bin/letsencrypt" certonly $vhosts_arg \
                    --email "$email" -c /etc/letsencrypt/config.cli.ini \
                    --renew-by-default \
                    --server https://acme-v01.api.letsencrypt.org/directory

                if [ $? -eq 0 ]
                then
                    status='pass'
                else
                    status='fail'
                fi
            fi
        fi

        echo "$status"
    done

    service nginx restart
}

main $@
