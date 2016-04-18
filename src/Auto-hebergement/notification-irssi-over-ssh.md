Title: Notification irssi over SSH
Date: 2011-10-20 14:51
Tags: Libre, IRC, ssh

Depuis que je possède un serveur, j’ai en permanence un
[screen](https://www.gnu.org/software/screen/) qui tourne avec
[irssi](https://irssi.org/) pour suivre ce qu’il se passe sur IRC. Dernièrement
j’utilise aussi ce screen au travail en collaboration avec
Puisque non somme en mesure d’envoyer des messages, le travail nécessaire pour
envoyer un fichier est relativement faible.

Nous retrouvons notre script côté client qui lance des commandes selon la
première ligne reçue :
[bitlbee](https://www.bitlbee.org) pour discuter avec mes collègues via gtalk.
Autant les messages qui me sont destinés sur IRC peuvent attendre que je
retourne voir mon screen, autant ceux de gtalk doivent mettre notifiés de manière
visible.

Pour ce faire, il va falloir mettre en place, côté serveur, un script qui envoie
le message pour le récupérer côté client et l’afficher à l’écran. Travaillant
sous [i3](https://i3wm.org/) cela à compliqué la tâche.

## Côté serveur

Cette partie est librement inspirée de
[On-screen notifications from IRSSI over SSH](http://i.got.nothing.to/post/2010/06/21/On-screen-notifications-from-IRSSI-over-SSH)
puis récrite en python pour y inclure la [gestion des pièces
jointes](|filename|pieces-jointes-mutt-over-ssh.md).

Le script suivant, à placer dans le répertoire  *~/.irssi/script*, se contente
d’appeler la commande *notify-send* lorsqu’un message est mis en avant ou que vous
recevez un message privé.

[paste:https://git.homecomputing.fr/my-dotfiles/raw/4823c4090b13bf380f1b99d80466253556febf62/irssi/scripts/notify.pl]

*notify-send* est normalement fournit par le paquet
[libnotify-bin](https://packages.debian.org/stable/libnotify-bin) est permet
d’afficher un message à l’écran. Ici nous allons le remplacer par un script qui
envoie le message sur le port 8088 en local :

    :::python
    #!/usr/bin/env python

    import sys, socket

    HOST = 'localhost'
    PORT = 8088
    SUBJECT = sys.argv[1]
    MESSAGE = sys.argv[2]

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((HOST, PORT))
    s.sendall('NOTIFY ' + SUBJECT + '\n' + MESSAGE)
    s.close()

## Côté Client

Côté client, il faut commencer par rediriger le port distant 8088 vers le même
port en local, grâce à ces quelques lignes placées dans *~/.ssh/config* :

    Host irc.homecomputing.fr
        PermitLocalCommand yes
        LocalCommand ~/.ssh/ssh-listener.py
        RemoteForward 8088 localhost:8088

Couplé à un client qui va écouter le port pour renvoyer le message au système de
notification local :

[paste:https://git.homecomputing.fr/my-dotfiles/raw/master/ssh/ssh-listener.py]

Si vous utilisez un gestionnaire de fenêtre tel que Gnome, vous pouvez vous
arrêtez là, *notify-send* faisant le reste. Cependant si vous utilisez un
gestionnaire de fenêtre léger (ici, i3) la suite vous permettra d’afficher le message.

*notify-send* envoie les messages à un daemon qui se charge de les afficher, comme
il ne fait pas le travail que l’on souhaite, nous allons le remplacer par
[statnot](https://github.com/halhen/statnot), plus configurable, dans notre
fichier *~/.xinitrc* :

[paste:https://git.homecomputing.fr/my-dotfiles/raw/93d38771be838cab1fcd18cf374f2949d1080ad5/xinitrc]

Il nous reste plus qu’à configurer statnot correctement, pour i3 j’utilise
[dzen2](https://sites.google.com/site/gotmor/dzen) :

[paste:https://git.homecomputing.fr/my-dotfiles/raw/93d38771be838cab1fcd18cf374f2949d1080ad5/statnot/config.py]

Et voilà le résultat :

![Irssi notification over SSH](|filename|/images/irssi-notification.png)

Vous pouvez retrouver l’ensemble des mes fichiers de configuration
[ici](https://git.homecomputing.fr/my-dotfiles/).
