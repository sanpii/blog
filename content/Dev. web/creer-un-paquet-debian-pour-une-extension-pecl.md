Title: Créer un paquet Debian pour une extension PECL
Date: 2011-02-22 20:13
Tags: Debian, Libre, PHP, Debian

Ce billet est d'une simplicité ridicule (merci Debian), prenez le comme une
prise de note qui peut vous aider à garder un système cohérent sans demander
plus d'effort que *pecl install*.

Prenons l'exemple de l'extension [stem](http://pecl.php.net/package/stem). Nous
devons commencer par installer les dépendances pour la compilation et la
construction de paquet :

    :::bash
    # apt-get install  php5-dev dh-make-php fakeroot build-essential

On créé les fichiers pour l’empaquetage :

    :::bash
    $ dh-make-pecl --maintainer "sanpi <sanpi@homecomputing.fr>" stem

Notez l'existence des options *--depends* et *--build-depends* qui pourraient
vous être utiles pour gérer les dépendances de certaines extensions.

Et c'est parti :

    :::bash
    $ cd php-stem-1.5.0/
    $ dpkg-buildpackage

Il ne reste plus qu'à transférer le paquet sur votre serveur et à l'installer
avec dpkg :

    :::bash
    # dpkg -i php5-stem_1.5.0-1_i386.deb

Et éventuellement installer les dépendances :

    :::bash
    # apt-get install -f
