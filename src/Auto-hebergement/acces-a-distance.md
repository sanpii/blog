Title: Accès à distance
Date: 2009-09-17 20:23
Tags: Debian, Libre, ssh

Maintenant que vos système est installé, nous allons passer en revu un ensemble
de logiciel, en particulier leur configuration, afin de doter notre serveur de
divers services, tel que :

* accès à distance (c’est pour aujourd’hui !) ;
* serveur web ;
* serveur FTP ;
* serveur de courrier électronique ;
* et quelque autre plus ou moins utile selon vos besoins.

Nous allons donc commencer par le service d’accès à distance, indispensable
avant de pouvoir débrancher l’écran et le clavier de notre serveur.

Installation
------------

Travaillant sous Debian, je me contenterai de ce système pour décrire
l’installation et la configuration des programmes, mais si vous avez choisi une
autre plateforme, vous devriez pourvoir vous y retrouver sans problème.

Afin d’avoir un accès distant à notre machine, nous avons besoin d’installer un
serveur (non plus la machine mais un logiciel) pour
[SSH](http://fr.wikipedia.org/wiki/SSH) qui est un protocole de connexion
sécurisée.

    :::bash
    # apt-get install sshd

Et si ce n’est pas encore le cas, installer un client SSH sur votre poste de
bureau :

    :::bash
    # apt-get install ssh

Pour tester, à partir ce dernier :

    :::bash
    $ ssh ip.de.votre.serveur

Inutile d’épiloguer, si vous souhaitez monter votre propre serveur, vous devez
déjà connaître ses commandes et comme je vous l’annonçais en introduction, c’est
surtout la configuration qui nous intéresse.

Configuration
-------------

Tant que vous n’ouvrez pas le port 22 (pour par défaut pour le protocole SSH),
vous êtes en sécurité, je vous conseille donc d’attendre la fin de ce billet
pour l’ouvrir, pour information j’ai au moins une tentative d’intrusion sur mon
serveur par jour via SSH...

### Authentification par clés ssh

Parqu’il devient vite pénible de devoir saisir son mot de passe à chaque fois
que l’on se connecte via SSH, il est possible d’utiliser une paire de clés
privé/public sans mot de passe. Commencez par générer vos clés sur votre PC :

    :::bash
    $ ssh-keygen -t rsa

Laissez le mot de passe vide. Ensuite, transférez la clés sur votre serveur :

    :::bash
    $ ssh-copy-id -i ~/.ssh/id_dsa.pub sanpi@serveur

Même sans mot de passe, l’accès reste sécurisé. Cependant attention, n’importe
qui ayant accès à votre répertoire personnel sur votre PC pourra utiliser votre
clés ! Il semble exister une alternative avec ssh-agent, à explorer...

### Interdire l’accès par mot de passe

Maintenant que l’accès par clés fonctionne, autant désactiver l’accès classique
par mot de passe.

Pour cela, éditer le fichier /etc/ssh/sshd_config et modifier l’option
PasswordAuthentication à non :

    # Change to no to disable tunnelled clear text passwords
    PasswordAuthentication no

Et recharger la nouvelle configuration :

    :::bash
    # /etc/init.d/ssh reload

### Désactiver le compte root

Il n’y a aucune raison de se connecter directement en tant que root, par
conséquent autant désactiver ce compte et passer par la commande sudo pour
exécuter les tâches d’administration.

Si ce n’est pas encore fait, installez sudo :

    :::bash
    # apt-get install sudo

Lancez l’édition du fichier de configuration de sudo avec la commande :

    :::bash
    # visudo

Et décommentez la dernière ligne. Pour finir, il suffit d’ajouter votre
utilisateur courant au groupe sudo :

    :::bash
    # adduser sanpi sudo

Et désactiver le compte root :

    :::bash
    $ sudo passwd -l root
