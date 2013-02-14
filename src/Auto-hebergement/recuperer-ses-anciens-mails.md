Title: Récupérer ses anciens mails
Date: 2010-11-09 18:53
Tags: Debian, Libre, Email, Fetchmail

Reprenons notre série fleuve sur l’installation d’un serveur mail. Comme vous
ne m’avez sûrement pas attendu pour recevoir des mails, il serait donc
regrettable de devoir faire des allers-retours entre vos deux (voir plus)
boites le temps que vos contacts s’approprient votre nouvelle adresse. Voyons
comment régler ce problème.

Heureusement, il existe des logiciels, comme fetchmail, qui vont s’occuper de
récupérer vos mails depuis notre ancienne boite via POP3 pour ensuite les
livrer sur notre serveur SMTP.

    :::bash
    # apt-get install fetchmail

Contrairement à ce qui est précisé à la fin de l’installation, nous n’avons pas
besoin d’éditer le fichier */etc/default/fetchmail* car nous n’utiliserons pas
fetchmail comme un démon.

Nous allons simplement créer un fichier de configuration *~/.fetchmailrc* puis
nous appellerons fetchmail à intervalle régulier grâce à une tâche cron.

La syntaxe du fichier de configuration de fetchmail est simple à comprendre
(sinon man fetchmailrc devrait vous éclairer) :

    poll pop.gmail.com protocol POP3 user "sanpi@gmail.com" password "xxx"
    options ssl mda "/usr/lib/dovecot/deliver -d %T"

La première ligne spécifie le serveur POP3 auquel se connecter ainsi que le nom
d’utilisateur et le mot de passe, ensuite gmail nécessite une connexion
chiffrée, c’est ce que nous demandons, en enfin le logiciel qui sera utilisé
pour délivrer les messages.

Autre exemple avec un compte mail free :

    poll pop.free.fr protocol POP3 user "sanpi@free.fr" password "xxx"
    options mda "/usr/lib/dovecot/deliver -d %T"

Afin d’autoriser un utilisateur à utiliser le programme pour délivrer les mails
fourni par dovecot, il faut activer la socket master, dans le fichier
*/etc/dovecot.dovecot.conf* :

    socket listen {
      master {
        # Master socket provides access to userdb information. It’s typically
        # used to give Dovecot’s local delivery agent access to userdb so it
        # can find mailbox locations.
        #path = /var/run/dovecot/auth-master
        mode = 0660
        # Default user/group is the one who started dovecot-auth (root)
        #user =
        group = mail
      }
      …
    }

Dans ce cas, l’utilisateur doit être membre du groupe *mail*.

Il nous reste plus qu’à lancer fetchmail régulièrement, ici toutes les minutes,
en ajoutant la ligne suivante dans la crontab, grâce à la commande `crontab
-e` :

    # m h  dom mon dow   command
    * * * * * /usr/bin/fetchmail -s

Pensez à activer le transfert POP3 dans la configuration de votre compte (ce
n’est pas le cas par défaut sur gmail).

Dans la prochaine et dernière partie, nous verrons comment mettre un peu
d’ordre dans tous ces mails…
