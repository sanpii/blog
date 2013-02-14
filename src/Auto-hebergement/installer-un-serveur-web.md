Title: Installer un serveur web
Date: 2010-07-06 00:36
Tags: Debian, Libre, lighttpd, MySQL, PHP, web

Aujourd’hui nous allons installer un serveur LLMP (non pas LAMP, mais **L**inux
**L**ighttpd **M**ysql **P**HP).

Nous allons utiliser [lighttpd](http://www.lighttpd.net/) comme serveur HTTP qui
est plus léger que Apache, simple à configurer et convient parfaitement pour un
serveur personnel.

lightpd
-------

Le dernier élément du quatuor gagnant, le langage de script PHP. Il s’agit de la
phase de l’installation la plus compliquée (ça reste relatif…) puisqu’il va
falloir faire le lien entre le serveur HTTP, MySQL et PHP.

Commençons par installer l’interpréteur, mais nous avons également besoin du
module pour MySQL :

    :::bash
    # apt-get install php5 php5-mysql

À ce stade là, si vous essayez d’afficher une page écrite en PHP, le serveur
vous renverra le script directement sans l’interpréter tout simplement parce que
nous ne l’avons pas configurer pour qu’il fasse appel à PHP. Comme promis, nous
allons revenir sur l’activation de module pour lighttpd.

Nous avons déjà vu qu’il existait un certain nombre de configurations dans le
répertoire */etc/lighttpd/conf-available*. Pour les activer, il suffit de créer
un lien symbolique dans le répertoire */etc/lighttpd/conf-enable*, mais inutile
de passer par la commande *ln*, lighttpd est fournit avec quelques scripts qui
vont nous simplifier la vie : *lighty-enable-mod* et *lighty-disable-mod*.

Pour que PHP fonctionne, nous devons activer la configuration *fastcgi* (qui
active le module mod\_fastcgi pour lighttpd et configure l’interprétation de
scripts), sans oublier de redémarrer notre serveur :

    :::bash
    # lighty-enable-mod fastcgi
    # /etc/init.d/lighttpd restart

Voilà, vous pouvez maintenant héberger vos premiers sites web ! En attendant le
voir comment créer des hôtes virtuels et installer Drupal, je vous conseille
d’activer le module de configuration *userdir* qui vous permet de bénéficier
d’un répertoire public par utilisateur plutôt que de mettre tout vos sites dans
*/var/www*, ce qui nécessite des droits plus élevés.
