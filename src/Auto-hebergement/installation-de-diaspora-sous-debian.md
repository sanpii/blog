Title: Installation de Diaspora sous Debian
Date: 2010-09-16 05:50
Tags: Debian, Libre, diaspora
Status: draft

Ils se sont fait un peu attendre, mais le code source de Diaspora est maintenant
public ! Pour ceux qui reviennent de vacances, il s’agit d’une alternatives
libre à Facebook. Petit tours du propriétaire, mais surtout voyons comment
l’installer.

Disapora est écrit en Ruby et en Javascript, le premier commit date du 11 Juin
et nous en sommes actuellement (il y a une séance de débuggage en direct sur IRC
donc ça avance très vite) à près de 1900 commits. L’équipe de développement ne
semble pas avoir chômée, mais qu’en est il ? Quelle sont les fonctionnalités
présentes ?

Pour l’instant il s’agit du minimum, sur le fond : création d’album photo,
possibilité d’avoir des amis (sur votre instance de Disapora ou sur une autre,
de la même manière que pour statusnet), différents murs (famille, travail,
autre, …), poster des messages et des commentaires. Voilà pour l’instant.
C’est très rudimentaire, mais sur la forme cela l’est encore plus avec pas mal
de bugs (impossible de trouver comment ajouter une photo :().

Maintenant concernant l’installation, ce n’est pas insurmontable mais pour un
néophyte de Ruby, il faut tout installer. Par chance, sous Debian Sid, la
majeure partie des logiciels sont sous forme de paquets, alors allons-y :

    :::bash
    # apt-get install build-essential libxslt1.1 libxslt1-dev libxml2
    # apt-get install ruby-full
    # apt-get install mongodb
    # apt-get install rubygems
    # apt-get install imagemagick

Passons à l’installation des dépendances non packagées :

    :::bash
    # gem install bundler

Ensuite créons un clone du dépôt de Diaspora :

    :::bash
    $ git clone http://github.com/diaspora/diaspora.git&lt;br />$ cd diaspora

Lors du premier lancement, nous devons installer les dépendances liées à
Disapora :

    :::bash
    $ bundle install

Si comme moi, votre shell vous répond qu’il ne connaît pas *bunble*, il se
trouve dans le répertoire */var/lib/gems/1.8/bin/*. Un redémarrage de session
est peut être nécessaire pour mettre à jour le path ?

Avant de démarrer la base de données, je préfère créer un répertoire pour les
fichiers (par défaut */data/db*) :

    :::bash
    $ mkdir -p data/db
    # mongod --dbpath ./data/db/

*mongod* (mais quel drôle de nom…) tournant en avant-plan, ouvrons un second
terminal et remplissons la base de données avec les données par défaut :

    :::bash
    $ rake db:seed:tom

Nous pouvons enfin lancer le serveur de test :

    :::bash
    $ bundle exec thin start

Rendez-vous à l’adresse <http://localhost:3000> pour admirer le résultat
(user=tom/password=evankorth) :

![Diaspora en action](|filename|/images/diaspora.png)

Alors après l’avoir tester 5 minutes, ma conclusion va être simple : je ne pense
pas l’utiliser ! Ah vous voulez savoir pourquoi ? Tout simplement parce que
c’est écrit en ruby. En plus du serveur PHP sur un serveur personnel, je
m’imagine mal avoir un second serveur pour les applications web ; et franchement
pas convaincu par cette première démo.
