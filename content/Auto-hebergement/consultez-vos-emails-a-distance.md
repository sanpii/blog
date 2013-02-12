Title: Consultez vos emails à distance
Date: 2010-10-11 18:42
Tags: Debian, Libre, Email, Imap

Après avoir installé un [serveur
SMTP](/content/envoyer-et-recevoir-ses-premiers-mails)
pour envoyer et recevoir des emails, comme indiqué dans
l’[introduction](/content/installation-dun-serveur-de-mail-introduction),
nous allons installer un serveur IMAP afin de pouvoir consulter nos emails
depuis un autre ordinateur.

Le serveur utilisé est [dovecot](http://www.dovecot.org/). Je me contente
d’utiliser le protocole IMAP afin de pouvoir consulter mes mails de la même
manière depuis n’importe quel ordinateur (les mails restent sur le serveur). Si
vous souhaitez installer un serveur POP3 (pour vos utilisateurs, par exemple),
il suffit de remplacer les occurrences de *imap* par *pop3*.

Comme à l’accoutumé, commençons pas installer le serveur :

    :::bash
    # apt-get install dovecot-imapd

Dans le fichier */etc/dovecot/dovecot.conf*, nous pouvons renseigner les
fichiers de log :

    # Log file to use for error messages, instead of sending them to syslog.
    # /dev/stderr can be used to log into stderr.
    log_path = /var/log/dovecot/error

    # Log file to use for informational and debug messages.
    # Default is the same as log_path.
    info_log_path = /var/log/dovecot/info

Pour tester que tout fonctionne avec telnet nous devons autoriser
l’authentification avec le mot de passe en clair en décommentant l’option
*disable\_plaintext\_auth* :

    :::bash
    $ telnet 192.168.51.5 143
    Trying 192.168.51.5...
    Connected to 192.168.51.5.
    Escape character is '^]'.
    * OK Dovecot ready.
    > x LOGIN sanpi secret
    x OK Logged in.
    > x SELECT INBOX
    * FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
    * OK [PERMANENTFLAGS (\Answered \Flagged \Deleted \Seen \Draft \*)] Flags permitted.
    * 1 EXISTS
    * 0 RECENT
    * OK [UNSEEN 1] First unseen.
    * OK [UIDVALIDITY 1286421452] UIDs valid
    * OK [UIDNEXT 2] Predicted next UID
    x OK [READ-WRITE] Select completed.
    > x FETCH 1:* (FLAGS BODY[HEADER.FIELDS (DATE FROM)])
    * 1 FETCH (FLAGS (\Seen) BODY[HEADER.FIELDS (DATE FROM)] {87}
    Date: Thu,  7 Oct 2010 04:45:46 +0200 (CEST)
    From: sanpi@handy.homecomputing.fr

    )
    x OK Fetch completed.
    > x LOGOUT
    * BYE Logging out
    x OK Logout completed.
    Connection closed by foreign host.

Les commandes envoyées au serveur doivent commencer par un caractère quelconque,
ici il s’agit de « x » et les commandes que j’ai tapé sont précédé du caractère
« > ».

Vous pouvez aussi tester avec thunderbird comme le montre la figure suivante :

![Configuration thunderbird](|filename|/images/imap.png)

Notre serveur de mail commence à prendre forme puisqu’il nous est possible
d’envoyer, de recevoir et de consulter nos mails à distance.

Dans le prochain billet, nous finaliserons la configuration de la partie serveur
en mettant en place l’authentification pour le protocole SMTP et nous
optimiserons la manière dont sont stocké les mails sur le serveur.
