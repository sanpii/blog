Title: Installation de seeks sous Debian
Date: 2010-10-16 18:56
Tags: Debian, Libre, Seeks

Je vous présentais il y a quelques jours le méta moteur de recherche
[seeks](http://www.seeks-project.info/). L’installation se faisait à partir des
sources et pouvais être quelque peut fastidieuses. Les choses ont bien avancées
depuis puisque l’équipe de seeks vous propose un dépôt pour Debian.

Maintenant l’installation pourrait se passer de commentaires :

    :::bash
    # wget http://archive.sileht.net/seeks/seeks-lenny.list -O - | tee /etc/apt/sources.list.d/seeks.list
    # apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EC0FC7E8
    # apt-get update
    # apt-get install seeks

Il ne vous reste plus qu’à configurer votre serveur web comme
[précédemment](|filename|installer-son-moteur-de-recherche.md), la seule
différence étant le numéro du port par défaut qui a changé.

*[Documentation officielle](http://archive.sileht.net/seeks/install.html)*
