Title: Envoyer et recevoir ses premiers mails
Date: 2010-10-07 05:54
Tags: Debian, Libre, Email, Smtp

Suite à l’[introduction sur l’installation d’un serveur de
mail](|filename|installation-dun-serveur-de-mail-introduction.md),
voici la première partie consacrée au serveur SMTP.

Pure coïncidence, comme Hapodi, nous allons envoyer nos premiers mails ! Trêve
de plaisanterie, commençons par la commande habituelle pour installer un paquet,
je vous rappel qu’il s’agit de postfix :

    :::bash
    # apt-get install postfix

Lors de l’installation, il vous est demandé le type de serveur souhaité, nous
utiliserons une configuration du type *Site internet*, puis le nom de domaine
complet.

Vous pouvez ensuite installer la paquet mailutils afin de tester votre serveur
SMTP. Commençons par tester l’envoi de mail :

    :::bash
    $ mail unmailvalide@minitel.fr
    Cc:
    ubject: Test
    Mon premier message depuis mon propre serveur SMTP !

Après avoir tapé votre message, appuyez sur *enter* puis *Ctrl + D*.

Vous pouvez faire de même depuis votre ordinateur de bureau pour tester la
réception de mail :

    :::bash
    $ mail sanpi@[192.168.51.2]
    Cc:
    Subject: Test
    Merci pour ce premier message.

Ou, un peu plus compliqué, discuter directement avec le serveur via telnet :

    :::bash
    $ telnet 192.168.51.5 25
    Trying 192.168.51.5...
    Connected to 192.168.51.5.
    Escape character is '^]'.
    220 homecomputing.fr ESMTP Postfix (Debian/GNU)
    > HELO homecomputing.fr
    250 homecomputing.fr
    > MAIL FROM:sanpi@homecomputing.fr
    250 2.1.0 Ok
    > RCPT TO:sanpi@homecomputing.fr
    250 2.1.5 Ok
    > DATA
    354 End data with <CR><LF>.<CR><LF>
    > Merci pour ce premier message.
    > .
    250 2.0.0 Ok: queued as E73E6194F3
    > QUIT
    221 2.0.0 Bye
    Connection closed by foreign host.

J’ai ajouté le caractère « > » devant les lignes saisies. On commence par se
présenter au serveur puis on renseigne un par un les entêtes du mail (from et
to), le corps du message et l’on termine par *enter point* puis *enter*.

Du côté de notre serveur, on peux consulter notre nouveau message avec la
commande *mail* :

    :::bash
    $ mail
    "/var/mail/sanpi": 1 message1 nouveau
    >N   1 sanpi@homecompu jeu oct  7 04:06  12/549   sanpi@homecomputing.fr
    & 1
    Date: Thu,  7 Oct 2010 04:05:18 +0200 (CEST)
    From: sanpi@homecomputing.fr
    To: undisclosed-recipients:;

    Merci pour ce premier message.
    &

Petit problème, notre serveur est actuellement très permissif puisqu’il permet à
n’importe qui d’envoyer un message. Malheureusement postfix ne gère aucune
méthode d’authentification, nous allons devoir installer dovecot et nous
reviendrons à la configuration de postfix pour régler ce problème. En attendant,
n’ouvrez pas le port 25 de votre box, vous risqueriez de servir de relais pour
spammeur.
