Title: Installation d’un serveur Firefox sync
Date: 2011-02-19 15:13
Tags: Libre, Firefox, Weave

Firefox sync est un une extension pour Firefox (directement incluse dans
Firefox 4) qui permet de sauvegarder vos préférences, mots de passe et
historique de votre navigateur sur un serveur afin de les retrouver depuis
n’importe quel ordinateur.

Si Mozilla propose un serveur avec un minimum de sécurité (authentification et
chiffrement des données), vu la simplicité de l’installation, il serait dommage
de se priver d’un peu de décentralisation.

Installation
------------

Pour commencer, nous avons besoin de l’extension sqlite pour PHP :

    :::bash
    # apt-get install php5-sqlite

Et ensuite téléchargez le [serveur
minimal](http://people.mozilla.org/~telliott/weave_minimal.tgz) qu’il suffit de
décompresser dans le répertoire */www/data* :

    $ cd /var/www
    $ wget http://people.mozilla.org/~telliott/weave_minimal.tgz
    $ tar zxf weave_minimal.tgz

Configuration
-------------

Nous avons besoin de préciser à *lighttpd* l’emplacement de notre serveur, avec
une récriture d’URL simple :

    $HTTP["host"] == "sync.homecomputing.fr" {
      server.document-root = "/www/data/weave_minimal"
      url.rewrite-once = (
        "(.*)" => "/index.php/$0"
      )
    }

Et comme le précise le fichier *README*, il faut commencer par vous rendre à une
adresse inexistante, par exemple
[http://sync.homecomputing.fr/1.0/blah/info/collection]() et saisir le nom
d’utilisateur *blash* et n’importe quel mot de passe afin de créer la base de
données.

Vous pouvons maintenant créer notre utilisateur :

    :::bash
    # php create_user
    (c)reate, (d)elete or change (p)assword: c
    Please enter username: sanpi
    Please enter password: 1234
    sanpi created

Il ne vous reste plus qu’à configurer Firefox :

![Configuration de Firefox Sync](|filename|/images/weave.png)

Si votre serveur HTTP est configuré pour accepter les requêtes chiffrées via
https, je vous conseil fortement de l’utiliser à la place d’un simple http.

Si vous préférez, il est possible d’installer la version complète du serveur qui
utilise MySQL en suivant les instructions du [wiki de
Mozilla](https://wiki.mozilla.org/Labs/Weave/Sync/1.0/Setup).
