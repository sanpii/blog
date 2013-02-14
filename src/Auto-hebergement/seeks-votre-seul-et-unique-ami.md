Title: Seeks, votre seul et unique ami
Date: 2010-09-26 18:01
Tags: Debian, Libre, Seeks

Je pensez ajouter cette partie à la fin de l’[installation de
seeks](|filename|installer-son-moteur-de-recherche.md)
mais elle demande un peu de travail, mais le résultat en vaut la peine :
renvoyer les recherches effectuées par google, ou tout autre moteur de
recherche, sur notre moteur de recherche.

Avant de commencer, je vous conseille de mettre à jour votre fichier *index.php*
avec la nouvelle version (voir [Installer son moteur de
recherche](|filename|installer-son-moteur-de-recherche.md))
afin de corriger le problème avec l’ajout du moteur opensearch.

Revenons au sujet du jour. L’astuce utilisée est relativement simple puisqu’elle
utilise le système de proxy. Commençons par voir comment l’activer et nous
finirons par configurer firefox pour éviter de surcharger notre proxy.

Dans le fichier */usr/local/etc/seeks/config*, nous devons permettre à seeks
d’écouter sur l’adresse public de votre serveur :

    listen-address  [::]:8250

Ensuite, pour éviter que tout le monde utilise votre proxy, vous pouvez
restreindre son utilisation aux IP du réseau local :

    permit-access 192.168.51.0/24

Pour une raison inconnue, ceci ne fonctionne pas sur mon serveur (peut-être à
cause de l’IPv6 ?), j’ai donc simplement utilisé iptables :

    :::bash
    # iptables -A INPUT -p tcp --dport 8250 -j ACCEPT --source 192.168.51.0/24

Et voilà, le proxy est prêt à fonctionner. Vous pouvez tester en modifiant les
paramètres réseau de votre navigateur web. En cliquant sur [ce
lien](http://www.google.fr/search?q=fdn) vous devriez être redirigé vers votre
moteur de recherche. Petit problème, toutes vos demandes passe par le proxy. En
soit c’est plutôt une bonne chose, mais j’attendrai d’avoir une machine dédiée
pour ce genre de chose.

En attendant, si vous utilisez firefox, vous pouvez installer le module
[FoxyProxy](https://addons.mozilla.org/fr/firefox/addon/2464/) qui permet de
définir des règles automatiques pour choisir le proxy à utiliser. J’ai
simplement créé un proxy *seeks* qui n’est utilisé que pour certaines url :

[![Foxyproxy](|filename|/images/foxyproxy.png)](/sites/blog/files/users/user_1/foxyproxy.png)

N’oubliez pas de sélectionner l’option *Utilisez les proxies basés sur leurs
motifs et propriétés définis* grâce à l’icône dans la barre des tâches.
