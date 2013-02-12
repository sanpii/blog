Title: Stockage des mails et sécurisation SMTP
Date: 2010-10-13 10:00
Tags: Debian, Libre, Email, Smtp

Deux articles en un, le format utilisé pour stocker les mails sur le serveur
étant très simple, j’en profite pour vous expliquer comment sécuriser votre
serveur SMTP.

Format de stockage des mails
----------------------------

Il existe deux principaux formats de stockage des mails, le premier *mbox* est
celui actuellement utilisé. Il consiste à stocker l’ensemble des messages d’un
même dossier dans un seul fichier. En plus de rapidement poser des problèmes de
performances, nous risquons aussi d’atteindre la limite de la taille d’un
fichier.

C’est pour ces raisons que nous allons utiliser le second format, *Maildir*, qui
stocke chaque mail dans un fichier regroupé dans différents dossiers.

Commençons par préciser à postfix où il doit délivrer nos mails, dans le fichier
*/etc/postfix/main.cf* ajoutez la ligne suivante :

    home_mailbox = Maildir/

Et ensuite à dovecot où aller les chercher et sous quel format :

    mail_location = maildir:~/Maildir

Enfin redémarrons les serveurs pour que les changements soient pris en compte :

    :::bash
    # /etc/init.d/postfix restart
    # /etc/init.d/dovecot restart

Sécurisation SMTP
-----------------

Histoire que tout le monde ne puisse pas envoyer de mail depuis notre serveur
SMTP, nous devons obliger l’utilisateur à s’authentifier. Comme je l’ai évoqué
lors de l’[installation de
postfix](|filename|envoyer-et-recevoir-ses-premiers-mails.md),
ce dernier n’est pas capable de de gérer l’authentification, nous allons donc
utiliser dovecot qui lui propose un système de socket (Il existe d’autres
solutions que dovecot, comme SASL).

Dans le fichier */etc/dovecot/dovecot.conf*, il faut décommenter la partie en
rapport avec la socket cliente et renseigner les options comme ceci :

    # It’s possible to export the authentication interface to other programs:
    socket listen {
      #master {
        # Master socket provides access to userdb information. It’s typically
        # used to give Dovecot’s local delivery agent access to userdb so it
        # can find mailbox locations.
        #path = /var/run/dovecot/auth-master
        #mode = 0666
        # Default user/group is the one who started dovecot-auth (root)
        #user =
        #group =
      #}
      client {
        # The client socket is generally safe to export to everyone. Typical use
        # is to export it to your SMTP server so it can do SMTP AUTH lookups
        # using it.
        path = /var/spool/postfix/private/auth-client
        mode = 0660
        user = postfix
        group = postfix
      }
    }

Du côté de postfix, il nous suffit d’activer l’authentification :

    # Activer l’identification SASL
    smtpd_sasl_auth_enable = yes
    # Utiliser le service d’identification de Dovecot
    smtpd_sasl_type = dovecot
    smtpd_sasl_path = private/auth-client
    # Noter dans les en-têtes des messages l’identifiant de l’utilisateur.
    smtpd_sasl_authenticated_header = yes

Pour terminer, nous pouvons ajouter quelques règles afin de rejeter les demandes
invalides :

    # Règles pour accepter ou refuser une connexion.
    smtpd_client_restrictions =
      permit_mynetworks, # Nous autorisons les connexions depuis le réseau local
      permit_sasl_authenticated, # Nous autorisons les requêtes lorsque le client est correctement authentifié
      reject_rbl_client bl.spamcop.net, # Nous rejetons les IP provenant de domaines listés par spamcop
      sleep 1, # Nous attendons une seconde pour piéger les zombies
      reject_unauth_pipelining # Nous rejetons les commandes envoyées au mauvais moment

    # Règles pour accepter ou refuser un message, dès lors qu’on connaît le nom
    # de l’hôte de l’expéditeur (par sa commande HELO ou EHLO).
    smtpd_helo_restrictions =
      reject_invalid_helo_hostname # Nous refusons les noms d’hôte invalides.

    # Règles pour accepter ou refuser un message, dès lors qu’on connaît l’adresse
    # de l’expéditeur.
    smtpd_sender_restrictions =
        reject_unlisted_sender, # Nous refusons si l’expéditeur est inexistant dans notre domaine
        reject_unknown_sender_domain, # Nous refusons si le domaine de l’expéditeur n’a pas d’IP ou de MX
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_sender # Nous refusons si l’adresse de l’expéditeur n’est pas sous forme canonique

    # Règles pour accepter ou refuser un message, dès lors qu’on connaît le
    # destinataire (par la commande RCPT TO).
    smtpd_recipient_restrictions =
        reject_unlisted_recipient,
        reject_unknown_recipient_domain,
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_recipient,
        reject_unauth_destination

    # Niveau de sécurité TLS.
    smtpd_tls_security_level =
      may # Nous annonçons le support de STARTTLS mais il n’est pas obligatoire que le
          # client utiliser un chiffrement TLS.

Vous pouvez vous reporter à la [documentation de
postfix](http://www.postfix.org/postconf.5.html) pour connaître la signification
exacte de chaque option et les valeurs possibles.

À partir de maintenant, votre serveur est fonctionnel et sécurisé. Vous pouvez
ouvrir le port 25 de votre box pour commencer à envoyer et recevoir vos mails.
Malheureusement c’est sans compter sur l’idiotie humaine qui à transformé ce
mode de communication en poubelle publicitaire grâce au spam ! Vous vous rendrez
rapidement compte qu’en plus de recevoir des spams, vous êtes dans l’incapacité
d’envoyer des mails car ils sont souvent classés comme spams… Nous réglerons
ça dans le prochain billet !

*Les exemples de configuration de postfix proviennent du [wiki
auto-hébergement](http://wiki.auto-hebergement.fr/dokuwiki/serveurs/postfix)
sous licence [CC BY-SA](http://creativecommons.org/licenses/by-sa/3.0/)*
