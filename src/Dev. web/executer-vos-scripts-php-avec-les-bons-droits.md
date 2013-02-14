Title: Exécuter vos scripts PHP avec les bons droits
Date: 2010-09-23 04:27
Tags: Debian, Libre, lighttpd, PHP

Le problème avec la configuration actuel de notre serveur c’est que tous nos
scripts PHP sont exécutés avec l’utilisateur *www-data*, nous sommes donc obligé
de donner les pleins droits à certains répertoires ou fichiers pour qu’ils
puissent être modifié. Corrigeons cette aberration (surtout si vous souhaitez
ouvrir votre hébergement à d’autres personnes).

Commençons par installer suphp :

    :::bash
    $ apt-get install suphp-common

Le fichier de configuration */ect/suphp/suphp.conf* est relativement simple. Les
seules options que j’ai modifiées sont *min_uid* et *min_gid*, puisque j’ai des
applications dans */var/www*, pour y mettre l’id de *www-data* (ie: 33) et
*umask* à 0022 sinon les fichiers uploadés ne sont pas lisibles.

Ensuite, nous devons créer un nouveau fichier de configuration pour *lighttpd*,
par exemple */etc/lighttpd/conf-available/10-suphp.conf* :

    :::bash
    server.modules += ( "mod_setenv", "mod_cgi" )

    #$PHYSICAL["path"] =~ "\.php$" {
      setenv.add-environment = (
        "SUPHP_HANDLER" => "x-httpd-php"
      )
    #}

    cgi.assign = (
      ".php" => "/usr/lib/suphp/suphp"
    )

L’option *$PHYSICAL["path"]* n’étant disponible qu’à partir de la version 1.5.0
de *lighttpd*, pour l’instant elle est commentée.

Avant de redémarer, n’oubliez pas de désactiver le module *fastcgi-php* et
d’activer celui-ci.

Maintenant vous pouvez ouvrir le fichier de log de *suphp* et tester vos
différents sites :

    :::bash
    # tail -f /var/log/suphp/suphp.log

Si, comme mois, vous avez commencé par tout faire exécuter par l’utilisateur
*www-data*, vous risquez d’avoir un peu de travail. Vous allez sûrement devoir
remettre de l’ordre dans les utilisateurs et les droits de vos différents
sites. Voici une commande, qui devrait vous aider, que j’ai exécutée dans mon
répertoire :

    :::bash
    $ sudo chown -R sanpi: * && find -type f -exec chmod 644 {} \; && find -type d -exec chmod 755 {} \;

Une fois que tout fonctionne, vous pouvez mettre l’option *loglevel* à *warn*
pour éviter de surcharger vos log.
