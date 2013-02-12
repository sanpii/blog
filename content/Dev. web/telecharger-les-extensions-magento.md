Title: Télécharger les extensions Magento
Date: 2011-05-24 11:28
Tags: PHP, magento

J’ai le bonheur de travailler avec Magento, et ça commence plutôt mal :
impossible d’installer une extension via la belle interface pudroyeux 2.0 car
je suis derrière un proxy et impossible de télécharger le paquet depuis le
site.

Comme cela à le don de m’énerver, j’ai donc décidé d’aller fouiller au fin fond
du *downloader* pour trouver l’URL de l’archive.

Toutes les données interessantes se trouvent dans le fichier
[downloader/lib/Mage/Connect/Rest.php](https://github.com/magentomirror/magento-mirror/raw/magento-1.5/downloader/lib/Mage/Connect/Rest.php).

La clés (en version 2.0) resemblent à une URL mais se décompose en deux parties,
prenons comme exemple le module *WishlistPlus* dont la clés est
[http://connect20.magentocommerce.com/community/WishlistPlus]() :

* la première partie, jusqu’au dernier caractère / est l’URL du channel ;
* la seconde partie, jusqu’à la fin, est le nom du paquet ;
* la troisième partie, optionnelle, est le numéro de version.

Le point d’entrée est le fichier *releases.xml*, disponible à l’URL
[$channel/$package/releases.xml](), qui recense les différentes versions sous la
forme suivante :

    <?xml version="1.0"?>
    <releases>
      <r>
        <v>1.0.1</v>
        <s>stable</s>
        <d>2011-02-08</d>
      </r>
      <r>

        <v>1.0.2</v>
        <s>stable</s>
        <d>2011-02-08</d>
      </r>
      <r>
        <v>1.0.2.1</v>
        <s>stable</s>

        <d>2011-02-08</d>
      </r>
      <r>
        <v>1.0.2.2</v>
        <s>stable</s>
        <d>2011-02-12</d>
      </r>

      <r>
        <v>1.0.2.3</v>
        <s>stable</s>
        <d>2011-02-27</d>
      </r>
    </releases>

À partir du numéro de version, on en déduit simplement l’URL du paquet :
[$channel/$package/$version/$package-$version.tgz]().

Du coup, un p’tit code rapide pour me trouver l’URL :

http://git.homecomputing.fr/?p=magento-dl.git;a=blob_plain;f=magento_dl.php

Simplement utilisable avec *wget* pour télécharger l’archive :

    :::bash
    $ HTTP_PROXY=’tcp://127.0.0.1:8080’ php magento_dl.php WishlistPlus | wget -i -
    --2011-05-24 11:19:05--  http://connect20.magentocommerce.com/community/WishlistPlus/1.0.2.3/WishlistPlus-1.0.2.3.tgz
    Connexion vers 127.0.0.1:8080...connecté.
    requête Proxy transmise, en attente de la réponse...200 OK
    Longueur: 6301 (6,2K) [application/x-gzip]
    Sauvegarde en : «WishlistPlus-1.0.2.3.tgz»

    100%[====================================================================================================================>] 6 301       --.-K/s   ds 0,1s

    2011-05-24 11:19:06 (61,4 KB/s) - «WishlistPlus-1.0.2.3.tgz» sauvegardé [6301/6301]

    Terminé --2011-05-24 11:19:06--
    Téléchargé(s): 1 fichiers, 6,2K en 0,1s (61,4 KB/s)

Il reste deux petites corrections à effectuer :

* l’adresse du proxy n’est pas correctement extraite ;
* je suppose que les éléments du XML sont triés par date.

Si le cœur vous en dit, libre à vous de faire un fork du projet
[magento-dl](http://git.homecomputing.fr/?p=magento-dl.git) ;)
