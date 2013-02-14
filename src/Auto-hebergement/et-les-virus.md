Title: … et les virus
Date: 2010-10-20 21:37
Tags: Debian, Libre, Clamav, Email, Virus

Après les
[spams](|filename|pour-en-finir-avec-les-spams.md),
l’autre fléau dont nous devons nous occuper sont les virus.

Cette partie vous sera utile si vous mettez à disposition votre serveur de mail
pour des clients sous Microsoft Windows. Pour l’instant sous GNU/Linux il ne me
semble pas justifié de consommer des ressources pour se prémunir des virus.

Alors que pour spamassassin il nous suffisait de faire passer le message dans un
tuyau (*pipe*), pour l’anti-virus nous allons utiliser un port (10026 par
défaut) sur lequel sera envoyé le mail entrant et nous le récupérerons sur un
autre port (10025) s’il n’a pas été supprimé entre deux. Pour ce faire, dans le
fichier */etc/postfix/main.cf* :

    content_filter = scan:127.0.0.1:10026
    receive_override_options = no_address_mappings

Et dans */etc/postfix/master.cf* :

    scan      unix  -       -       n       -       16      smtp
      -o smtp_send_xforward_command=yes
    127.0.0.1:10025 inet  n -       n       -       16      smtpd
      -o content_filter=
      -o receive_override_options=no_unknown_recipient_checks,no_header_body_checks
      -o smtpd_helo_restrictions=
      -o smtpd_client_restrictions=
      -o smtpd_sender_restrictions=
      -o smtpd_recipient_restrictions=permit_mynetworks,reject
      -o mynetworks_style=host
      -o smtpd_authorized_xforward_hosts=127.0.0.0/8

Comme pour les spams, il existe un mail générique que clamav va automatiquement
détecter comme un virus :

    X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*

Vous pouvez surveiller les logs de réception des mails pour vérifier que le mail
est bien supprimé :

    # tail -f /var/log/mail.log
    Oct 16 21:22:54 giggles postfix/smtpd[6506]: connect from unknown[192.168.51.4]
    Oct 16 21:22:55 giggles postfix/smtpd[6506]: 365A819504: client=unknown[192.168.51.4]
    Oct 16 21:22:55 giggles postfix/cleanup[6511]: 365A819504: message-id=<4CB9FB79.1020106@homecomputing.fr>
    Oct 16 21:22:55 giggles postfix/qmgr[6499]: 365A819504: from=<sanpi@homecomputing.fr>, size=898, nrcpt=1 (queue active)
    Oct 16 21:22:55 giggles postfix/smtpd[6506]: disconnect from unknown[192.168.51.4]
    Oct 16 21:22:55 giggles postfix/pickup[6498]: 5A47019508: uid=107 from=<sanpi@homecomputing.fr>
    Oct 16 21:22:55 giggles postfix/cleanup[6511]: 5A47019508: message-id=<4CB9FB79.1020106@homecomputing.fr>
    Oct 16 21:22:55 giggles postfix/pipe[6512]: 365A819504: to=<sanpi@[192.168.51.5]>, relay=spamassassin, delay=1.3, delays=1.2/0.01/0/0.13, dsn=2.0.0, status=sent (delivered via spamassassin service)
    Oct 16 21:22:55 giggles postfix/qmgr[6499]: 365A819504: removed
    Oct 16 21:22:55 giggles postfix/qmgr[6499]: 5A47019508: from=<sanpi@homecomputing.fr>, size=1230, nrcpt=1 (queue active)
    Oct 16 21:22:55 giggles clamsmtpd: 100000: accepted connection from: 127.0.0.1
    Oct 16 21:22:55 giggles postfix/smtpd[6518]: connect from localhost[127.0.0.1]
    Oct 16 21:22:55 giggles postfix/smtpd[6518]: 73A9319506: client=localhost[127.0.0.1]
    Oct 16 21:22:55 giggles clamsmtpd: 100000: from=sanpi@homecomputing.fr, to=sanpi@[192.168.51.5], status=VIRUS:Eicar-Test-Signature(f079fa479d272525a158e63decc82bcc:71)
    Oct 16 21:22:55 giggles postfix/smtp[6516]: 5A47019508: to=<sanpi@[192.168.51.5]>, relay=127.0.0.1[127.0.0.1]:10026, delay=0.13, delays=0.02/0.01/0.08/0.01, dsn=2.0.0, status=sent (250 Virus Detected; Discarded Email)
    Oct 16 21:22:55 giggles postfix/qmgr[6499]: 5A47019508: removed
    Oct 16 21:22:55 giggles postfix/smtpd[6518]: disconnect from localhost[127.0.0.1]

Si vous souhaitez que votre correspond soit informé qu’il a tenté de vous
envoyer un virus, vous pouvez activer l’option *Bounce* dans le fichier
*/etc/clamsmtpd.conf* :

    # Whether or not to bounce email (default is to silently drop)
    Bounce: on

Si vous souhaitez garder les messages suspects, vous pouvez activer l’option
*Quarantine*, ils seront alors stockés dans le répertoire temporaire, par défaut
*/var/spool/clamsmtp*.
