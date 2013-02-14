Title: Installation d’un serveur d’e-mail - introduction
Date: 2010-07-13 00:53
Tags: Debian, Libre, email, imap, pop3, smtp

Nous allons commencer une série d’articles afin de couvrir l’installation d’un
serveur de mails.

Cette première n’est qu’une introduction afin de placer les choses dans leur
contexte.

Le serveur de mail est sûrement le serveur le plus compliqué que j’ai eu à
installer. Premièrement parce que ma connaissance dans ce domaine était proche
de zéro et deuxièmement un serveur de mail est en fait composé de plusieurs
éléments qui doivent communiquer entre eux :

* un serveur SMTP pour l’envoi du courier ;
* un serveur POP3 et/ou IMAP pour la consultation du courier ;
* un anti-spam ;
* un filtre de mail (afin d’envoyer les mails dans le dossier approprié) ;
* un client mail.

Le rôle du protocole SMTP (et donc du serveur associé) est d’envoyer et de
recevoir des courriels. Comme souvent dans le monde Unix c’est la seule chose
qu’il sait faire mais il ne fait bien. Nous utiliserons le plus connu, à savoir
*postfix*.

Une fois le courriel reçu sur votre serveur, vous devons pouvoir le consulter,
c’est ici qu’intervient le serveur POP3 ou IMAP. Le protocole POP3 permet de
récupérer ses messages sur son ordinateur alors que le protocole IMAP permet
simplement de les consulter, les messages restent sur le serveur. Comme je
souhaite pourvoir accéder à mes messages partout, j’ai opté pour le protocole
IMAP. Dans tous les cas le serveur utilisé, *dovecot* gère les deux.

Afin d’éviter cette plaie que sont les spams (et encore ce que vous recevait
dans votre boite ne sont qu’une partie du travail, vous aller dévouvrir l’envers
du décor) nous allons coupler le serveur SMTP avec un filtre anti-spam :
*spamassassin*.

Comme nous ne sommes pas à l’abris de faux-positif, nous allons quand même
recevoir les spams dans notre boite de réception, mais utiliser *sieve* (qui est
un protocole disponible avec *dovecot* sous forme de greffon) qui va nous
permettre de déplacer les courriels indésirables dans le dossier correspondant
(entre autre…).

Et pour finir, il nous faut un logiciel pour lire notre courrier, j’ai choisi
d’avoir d’un côté *thunderbird* sur mon PC de bureau et d’un autre *roundcube*
afin de consulter mes messages en dehors de chez moi.

J’ai commencé l’année dernière à installer mon serveur d’emails sans *sieve* et
*thunderbird* et j’étais revenu à *gmail* car je trouvais le système de libellé
extrêmement pratique, si je commence cette série d’articles aujourd’hui c’est
que j’ai réussi à retrouver ce système avec *thunderbird* (en mieux même puisque
l’on peut mixer libellé et dossiers), mais pour obtenir ce résultat il faut
falloir vous accrocher, en espérant que mes conseils vous simplifierons la
tâches.

A suivre…
