Title: Triez vos emails
Date: 2010-12-27 14:31
Tags: Debian, Libre, Email, Sieve

Comme nous l’avons vu lors de l’[installation de
spamassassin,](/content/pour-en-finir-avec-les-spams) il serait intéressant de
pouvoir trier nos messages. Il existe bien des solutions pour le faire côté
client, par exemple avec thunderbird, mais premièrement comme nous serons amené
à utiliser plusieurs clients, il faudra refaire notre configuration à chaque
fois et deuxièmement, il est plus logique de trier les messages lors de leur
arrivée sur le serveur qu’à postériorie par le client.

Pour ce faire, nous allons utiliser le protocole sieve qui est décrit dans la
[RFC 5229](http://tools.ietf.org/html/rfc5228) et parfaitement supporté par
dovecot, nous devons juste activer le greffon.

Comme le filtrage des messages s’effectue lors de la réception des messages, il
faut commencer par demander à postfix d’utiliser le LDA de dovecot pour
délivrer les mails :

    mailbox_command = /usr/lib/dovecot/deliver

Toutes les modifications qui vont suivent sont à effectuer dans le fichier
*/etc/dovecot/dovecot.conf*. Commencez par activer le protocole *managesieve* :

    protocols = imap imaps managesieve

Ensuite il faut configurer le protocole :

    protocol managesieve {
      # Login executable location.
      login_executable = /usr/lib/dovecot/managesieve-login

      # MANAGESIEVE executable location. See IMAP’s mail_executable above for
      # examples how this could be changed.
      mail_executable = /usr/lib/dovecot/managesieve

      # Maximum MANAGESIEVE command line length in bytes. This setting is
      # directly borrowed from IMAP. But, since long command lines are very
      # unlikely with MANAGESIEVE, changing this will not be very useful.
      #managesieve_max_line_length = 65536

      # Specifies the location of the symlink pointing to the active script in
      # the sieve storage directory. This must match the SIEVE setting used by
      # deliver (refer to http://wiki.dovecot.org/LDA/Sieve#location for more
      # info). Variable substitution with % is recognized.
      sieve=~/.dovecot.sieve

      # This specifies the path to the directory where the uploaded scripts must
      # be stored. In terms of ’%’ variable substitution it is identical to
      # dovecot’s mail_location setting used by the mail protocol daemons.
      sieve_storage=~/sieve

      # If, for some inobvious reason, the sieve_storage remains unset, the
      # managesieve daemon uses the specification of the mail_location to find out
      # where to store the sieve files (see explaination in README.managesieve).
      # The example below, when uncommented, overrides any global mail_location
      # specification and stores all the scripts in ’~/mail/sieve’ if sieve_storage
      # is unset. However, you should always use the sieve_storage setting.
      mail_location = maildir:~/Maildir

      # To fool managesieve clients that are focused on timesieved you can
      # specify the IMPLEMENTATION capability that the dovecot reports to clients
      # (default: dovecot).
      #managesieve_implementation_string = Cyrus timsieved v2.2.13
    }

Étonnamment les options *login_executable* et *mail_executable* ont des valeurs
par défaut incorrectes, nous devons donc les redéfinir.

Ensuite nous définissons le répertoire où seront situé les différents fichiers
de paramétrage pour sieve (*sieve_storage*), sachant que seul le fichier pointé
par l’option *sieve* sera actif. Et pour terminer avec cette partie, nous
devons redéfinir l’endroit où sont stocké les mails.

Sans oublier de configurer le LDA :

    protocol lda {
      # Address to use when sending rejection mails.
      postmaster_address = postmaster@homecomputing.fr

      # Hostname to use in various parts of sent mails, eg. in Message-Id.
      # Default is the system’s real hostname.
      #hostname =

      # Support for dynamically loadable plugins. mail_plugins is a space separated
      # list of plugins to load.
      #mail_plugins =
      #mail_plugin_dir = /usr/lib/dovecot/modules/lda

      # Binary to use for sending mails.
      #sendmail_path = /usr/lib/sendmail

      # UNIX socket path to master authentication server to find users.
      #auth_socket_path = /var/run/dovecot/auth-master

      # Enabling Sieve plugin for server-side mail filtering
      mail_plugins = cmusieve
    }

Nous avons simplement a renseigner l’option *postmaster_adresse* et activer le
greffon *cmusieve*.

Terminons par créer le répertoire qui va contenir nos fichiers et notre premier
fichier :

    $ mkdir ~/sieve
    $ touch ~/sieve/default.sieve

Et l’activer :

    $ ln -s ~/sieve/default.sieve ~/.dovecot.sieve

Quelques exemples de filtres
----------------------------

Voici un agrégat de recettes afin de gérer au mieux vos mails.

Commençons pas le plus important, envoyer les messages indésirables dans le
répertoire approprié :

    require "fileinto";

    if header :contains "X-Spam-Flag" "YES" {
      fileinto "Junk";
      stop;
    }

Si vous souhaitez filtrer les messages issues de listes de diffusions :

    if exists "List-Id" {
      fileinto "INBOX.Mailinglist";
    }

*INBOX.MailingList* étant un sous-répertoire de la boite de réception.

Pour les utilisateurs de gmail, le protocole imap gère les étiquettes et il est
possible d’utiliser sieve pour les ajouter automatiquement. Par exemple pour
mettre en évidence vos messages [récupérer de votre ancienne
boite](/content/recuperer-ses-anciens-mails) :

    require "imapflags";

    if address :contains "To" "sanpi@gmail.com" {
      addflag "gmail";
    }

Vous pouvez consulter la [documentation de
dovecot](http://wiki.dovecot.org/LDA/Sieve#Example_scripts) pour de plus amples
exemples.

Concernant les étiquettes, il faut également les créer dans thunderbird
(Édition > Préférences > Affichages > Étiquettes). Toujours pour thunderbird,
si vous souhaitez pouvoir modifier rapidement vos filtres, vous pouvez utiliser
le greffon [sieve](https://addons.mozilla.org/fr/thunderbird/addon/2548/) qui
n’est qu’un éditeur de texte qui utilise le protocole managesieve mais qui à la
bonne idée d’intégrer un analyseur syntaxique et une aide sur le protocole
sieve.
