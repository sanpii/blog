Title: Se protéger des accès intempestif
Date: 2009-10-07 22:46
Tags: Debian, Libre, fail2ban

Pour m’excuser du temps entre la publication des deux derniers billets (je
souhaitez écrire un billet par jour…), en voici un second, certes court mais
très appréciable : l’installation de fail2ban.

Maintenant que votre accès SSH est correctement sécurisé, vous risquez de voir
apparaître dans votre fichier /var/log/auth.log des demandes d’accès refusées,
si certains robots ne testent que quelques login, certains font tout l’alphabet
! Pour éviter de surcharger votre serveur inutilement, nous allons donc
installer fail2ban.

Qu’est ce que fail2ban
----------------------

Il s’agit d’un démon qui va scruter vos fichiers de log afin de repérer les
tentatives d’accès frauduleuse à votre serveur et bannir les IP responsables.

Installation
------------

Inutile d’épiloguer, vous devez commencer à être habitué :

    :::bash
    $ sudo apt-get install fail2ban

Configuration
-------------

Pour l’instant pas grand chose... C’est ce que j’apprécie chez Debian : les
outils ont une configurations par défaut acceptable pour une utilisation
classique.

Vous pouvez tout de même éviter de vous bannir vous même lorsque vous êtes sur
votre réseau local. Dans le fichier /etc/fail2ban/jail.conf décommentez la ligne
ignoreip :

    # "ignoreip" can be an IP address, a CIDR mask or a DNS host
    ignoreip = 192.168.0.0/24

Pour l’instant vous pouvez voir les action effectuée dans le fichier
/var/log/fail2ban.log et voir les bannissements actif avec la commande :

    :::bash
    $ sudo iptables -L

Nous verrons au fur et à mesure de l’installation des autres services comment
adapter fail2ban à nos besoins et recevoir un mail à chaque actions effectuées.
