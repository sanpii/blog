Title: Pour en finir avec les spams
Date: 2010-10-18 19:59
Tags: Debian, Libre, Email, Spam

En ce début de semaine, nous allons parler de la gestion des spams.

SPAM ou "Spiced Ham" (« jambon épicé », en français) est une viande précuite en
boîte qui été largement utilisée par l’intendance des forces armées américaines
pour la nourriture des soldats pendant la Seconde Guerre mondiale et sera
introduite dans diverses régions du monde à cette occasion (cf Wikipedia).

Ah désolé on me fait signe que ce n’est pas de nourriture dont il est question
aujourd’hui, mais de courrier indésirable. Pour l’histoire le terme viendrais
d’un sketch des Monty Python :

Après cette parenthèse culturelle et avant de nous lancer dans le sujet du jour,
si ce n’est pas encore fait, je vous invite à configurer un client de messagerie
lourd ou léger, j’ai choisi respectivement
[thunderdird](http://www.mozillamessaging.com/fr/) et
[roundcube](http://roundcube.net/). L’installation étant d’une simplicité
extrême il me semble pas utile de l’aborder ici (thunderbird devrais détecter
tout seul le port et le chiffrement utilisé).

<object width="480" height="371"><param name="movie" value="http://www.dailymotion.com/swf/video/x3a5yl?additionalInfos=0"></param><param name="allowFullScreen" value="true"></param><param name="allowScriptAccess" value="always"></param><embed type="application/x-shockwave-flash" src="http://www.dailymotion.com/swf/video/x3a5yl?additionalInfos=0" width="480" height="371" allowfullscreen="true" allowscriptaccess="always"></embed></object>

Afin de nous préserver de cette plaie numérique, nous allons installer un
anti-spam, le plus connu, à savoir spamassassin. Son fonctionnement est
relativement simple puisque l’on va rediriger les mails que nous recevons vers
spamassassin qui va effectuer un certain nombre de tests afin de donner un score
au message. Si le score dépasse une certaine valeur (5 par défaut) le sujet du
mail sera réécrit pour contenir le terme \*\*\*|\*\*SPAM\*\*\*|\*\* et des
entêtes supplémentaires seront ajoutés ce qui nous permettra de déplacer le
message vers un dossier plus approprié.

L’installation ne devrait plus avoir de secret pour vous :

    :::bash
    # apt-get install spamassassin

Par contre la configuration, chose étonnante sous Debian, va être plus
laborieuse qu’à l’acoutumée. Nous devons d’avord créer un utilisateur spécifique
à spamassassin :

    :::bash
    # useradd --home /var/spamassassin --create-home --system spamd

Cet utilisateur servira à lancer le démon et son répertoire personnel contiendra
les informations d’apprentissages.
Dans */etc/default/spamassassin*, nous activons le mode démon de spamassassin et
nous lui passons le nom de l’utilisateur à utiliser :

    # Change to one to enable spamd
    ENABLED =1
    # Options
    # See man spamd for possible options . The -d option is automatically added .
    # SpamAssassin uses a preforking model , so be careful ! You need to
    # make sure --max-children is not set to anything higher than 5 ,
    # unless you know what you’re doing .
    OPTIONS ="--create-prefs --max-children 5 --usernam spamd -H /var/spamassassin -s /var/log/spamd.log"

Nous pouvons maintenant lancer le démon :

    :::bash
    # /etc/init.d/spamassassin start

Ensuite, il faut préciser à postfix d’envoyer tous les messages reçus par le
filtre spamassassin. Pour ce faire nous ajouter une option au début du fichier
*/etc/postfix/master.cf* :

    smtp          inet n            -        -          -         -          smtpd
       -o content_filter=spamassassin

Puis nous définition le filtre à la fin de ce même fichier :

    spamassassin unix -             n        n          -         -          pipe
       user=spamd argv=/usr/bin/spamc -f -e
       /usr/sbin/sendmail -oi -f ${sender} ${recipient}

Il nous reste plus à recharger la configuration de postfix :

    :::bash
    # postfix reload

Pour tester, vous pouvez commencez par vous envoyer un mail normal tout en
gardant un oeuil sur le fichier de log, à savoir */var/log/mail.err* mais le
plus important est de pouvoir tester la détection des spams. Pour ce faire il
existe un test générique pour les couriers indésirables ou
[GTUBE](http://spamassassin.apache.org/gtube/) qui sera à coût sûr détecter
comme spam par spamassassin. Il suffit de vous envoyer un mail contenant la
chaîne suivante dans le corps :

    XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X

Vous receverez un message modifié par spamassassin qui vous précise, entre
autre, les raisons de la classification du message comme indésirable avec le
détail du score et le message en pièce jointe. Nous verrons bientôt comment
rediriger ces messages dans le dossier approprié.

Se débloquer des listes noires
------------------------------

Maintenant que nous avons réglé le problème des spams en entrée, il faut faire
de même pour les couriels sortant. Il faut savoir qu’il existe des services qui
permettent d’améliorer la détection des spams (à l’image de spamcop) que nous
avons utilisé dans la partie [sécurisation
SMTP](|filename|stockage-des-mails-et-securisation-smtp.md).

Il existe plusieurs bases de données, les trouver et demander sa suppression de
chacune d’elle pourrait être laborieux, heureusement il existe des sites qui
vous proposent d’intérroger plusieurs dizaines d’entre eux, comme par exemple
[mxtoolbox](http://mxtoolbox.com/blacklists.aspx).

La principale cause de blocage vient du fait que votre FAI déclare votre IP
comme étant une IP pour particulier qui n’est pas sensée envoyer d’email. Il
vous suffit de suivre les conseils qui vous sont proposés et généralement
d’envoyer un message pour confirmer que vous n’êtes pas un méchant spammeur.

Au passage, vous pouvez explorer le reste du site mxtoolbox afin de vérifier que
votre client est correctement configuré.
