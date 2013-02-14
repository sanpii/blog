Title: Installer son moteur de recherche
Date: 2010-09-24 08:06
Tags: Debian, Libre, Seeks

Après mon article sur [comment occuper votre serveur
web](/content/comment-occuper-son-serveur-web),
je pense que vous êtes devenu relativement indépendant concernant les services
web, mais il en reste un, qui pour ma part représente une grande part de mes
visites : le moteur de recherche.

Quand j’ai demandé sur sur IRC, quel moteur de recherche je pourrais utiliser
pour remplacer google, on m’a rapidement répondu
[seeks](http://www.seeks-project.info/). Seeks est un méta-moteur de recherche
Libre. Si vous voulez vous faire une idée, vous pour tester sur
[seeks.fr](http://www.seeks.fr/), mais il est bien plus intéressant d’avoir
votre propre noeud.

[Téléchargez](http://www.seeks-project.info/wiki/index.php/Download#Download) la
version de votre choix, pour information, je me suis basé sur la version
experimental.

Installez les dépendances, en supposant que vous ayez déjà les autotools et un
compilateur C++ d’installé :

    :::bash
    # apt-get install libcurl3-gnutls-dev libpcre3-dev libxml2-dev

La compilation et l’installation est d’une banalité affligeante :

    :::bash
    $ ./autogen.sh
    $ ./configure
    $ make
    # make install

Si vous avez laisser le préfix d’installation par défaut (*/usr/local*), lancez
la commande *ldconfig* en root pour être sûr que les bibliothèques dynamiques
soient trouvées.

Vous pouvez lire le fichier de configuration */usr/local/etc/seeks/config* afin
d’affiner les paramètres qui, par défaut, fonctionnent parfaitement. Voici les
quelques changements opérés :

* *listen-address [::1]:8118*, pour le rendre compatible IPv6 ;
* *hostname seeks.homecomputing.fr*, pour modifier le nom du noeud ;
* *max-client-connections 256*, il y avait quelques zéros surnuméraires
(probablement un oubli) ;
* *logdir /var/log/seeks*.

Vous pouvez déjà lancer le moteur pour vérifier que tout fonctionne :

    :::bash
    $ seeks

Ensuite, nous devons mettre en place l’interface web. Vous pouvez vous reportez
au [wiki](http://www.seeks-project.info/wiki/index.php/Seeks_On_Web) si vous
n’utlisez par lighttpd et PHP.

La configuration de lighttpd reste élémentaire :

    $HTTP["host"] == "seeks.homecomputing.fr" {
        server.document-root = "/var/www/seeks"
        url.rewrite-once = (
            "(.*)" => "/index.php/$0"
        )
        accesslog.filename = "/dev/null"
        server.errorlog = "/dev/null"
    }

Et enfin notre fichier */var/www/seeks/index.php* :

    :::php
    <?php

    /*
     * Copyright Camille Harang
     * Copyright (C) 2010 Nicolas Joseph
     *
     * This program is free software: you can redistribute it and/or modify
     * it under the terms of the GNU Affero General Public License as
     * published by the Free Software Foundation, either version 3 of the
     * License, or (at your option) any later version.
     *
     * This program is distributed in the hope that it will be useful,
     * but WITHOUT ANY WARRANTY; without even the implied warranty of
     * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
     * GNU Affero General Public License for more details.
     *
     * You should have received a copy of the GNU Affero General Public License
     * along with this program. If not, see http://www.fsf.org/licensing/licenses/agpl-3.0.html.
     */

    $proxy = 'localhost:8118';
    $hostname = 'seeks.homecomputing.fr';

    if (!empty ($_SERVER['HTTPS']))
    {
      $scheme = 'https://';
    }
    else
    {
      $scheme= 'http://';
    }

    $seeks_uri = 'http://s.s';
    if ($_SERVER['REQUEST_URI'] == '/')
    {
      $base_url = $scheme.$_SERVER['HTTP_HOST'];
      $url = $base_url.'/websearch-hp';
    }
    else
    {
      $base_script = $_SERVER['SCRIPT_NAME'];
      $url = $seeks_uri.str_replace ($base_script, '', $_SERVER['REQUEST_URI']);
    }

    $data = array (
      'http' => array (
        'proxy' => $proxy,
      ),
    );
    $context = stream_context_create ($data);
    $result = file_get_contents ($url, false, $context);

    header ('Content-Type: '.$result_info['content_type']);
    /* @BUG #130 */
    if ($_SERVER['REQUEST_URI'] == '/opensearch.xml')
    {
      $result = str_replace ('/public', $scheme . $hostname . '/public', $result);
      $result = str_replace ('/search', $scheme . $hostname . '/search', $result);
    }
    echo $result;

Pour lancer le moteur en arrière plan, je me suis inspiré du wiki en plaçant
ceci dans la crontab :

    */5 * * * * [ ! -f /var/run/seeks.pid -o -z "$(cat /var/run/seeks.pid 2>/dev/null )" -o ! -d "/proc/$(cat /var/run/seeks.pid 2>/dev/null)" ] && seeks --daemon --pidfile /var/run/seeks.pid

Ce qui permet de relancer le moteur en cas de problème.
