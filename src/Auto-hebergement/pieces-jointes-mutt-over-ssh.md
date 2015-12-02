Title: Pièces jointes mutt over SSH
Date: 2011-11-16 17:36
Tags: Libre, Mutt, ssh, Email

Après les [notifications](/content/notification-irssi-over-ssh), le second point
gênant pour les accrocs de ssh est la visualisation des pièces jointes des mails
depuis [mutt](http://www.mutt.org/).

Puisque nous sommes en mesure d’envoyer des messages, le travail nécessaire pour
envoyer un fichier est relativement faible.

Nous retrouvons notre script côté client, amputé des commandes inutiles et
amélioré pour lancer des commandes selon la première ligne reçue :

[paste:http://git.homecomputing.fr/my-dotfiles/raw/master/ssh/ssh-listener.py]

Par exemple, pour les notifications, il suffit envoyer :

    NOTIFY Summary
    The message

Et côté serveur, un script (cette fois-ci en python, question d’homogénéité) qui
envois la commande *SEND* suivi du nom du fichier et de son contenu :

    :::python
    #!/usr/bin/env python

    import sys, socket

    HOST = 'localhost'
    PORT = 8088
    FILE = sys.argv[1]

    f = open(FILE, 'rb')
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((HOST, PORT))
    s.sendall('SEND ' + FILE + '\n' + f.read())
    s.close()

Il nous reste plus qu’à configurer mutt pour qu’il appelle notre script lors de
l’ouverture d’une pièce jointe. Ceci se fait par l’intermédiaire du fichier
*~/.mailcap* :

    text/*; /usr/local/bin/attachment-send.py %s
    application/*; /usr/local/bin/attachment-send.py %s
    image/*; /usr/local/bin/attachment-send.py %s
    audio/*; /usr/local/bin/attachment-send.py %s

Pour finir, deux remarques :

  * la commande *see* aura le même comportement ;
  * mes tests ont été négatif, mais gardez à l’esprit qu’une personne pourrait
    ouvrir un fichier sur votre machine en vous envoyant un message via IRC.
