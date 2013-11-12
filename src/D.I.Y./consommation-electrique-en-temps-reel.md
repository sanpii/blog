Title: Consommation électrique en temps réel
Date: 2013-10-22
Tags: raspberry, téléinfo

J’écris ce billet suite à la lecture d’un article dans [Open silicium
n°8](http://boutique.ed-diamond.com/open-silicium/497-os8.html) qui m’a
extrêmement déçus. En plus d’utiliser une solution toute prête, sur trois
outils pour visualiser les données, un seul est libre.

![Open silicium n°8](|filename|/images/teleinfo/open-silicium-8.png)

Comme j’avais déjà étudié le sujet et avais les composants sous la main, je vais
donc écrire l’article que je m’attendais à lire.

## Télé-info

Plus précisément, la télé-information client, est une norme
([ERDF-NOI-CPT\_02E](http://www.erdfdistribution.fr/medias/DTR_Racc_Comptage/ERDF-NOI-CPT_02E.pdf))
proposée pas ERDF pour que le client puisse récupérer des informations de son
compteur en temps réel.

Pour ce faire, les compteurs actuellement utilisés disposent d’un bus constitué
de deux bornes. Sur mon compteur, ils sont situés sous le capo inférieur de
compteur (celui qui n’est pas plombé) et sont notés I1 et I2.

### Modulation

En connectant un oscilloscope à ces bornes, nous observons une porteuse d’une
fréquence de 50 kHz transportant des informations binaires modulées ainsi
(§ 1.3) :

* vitesse de modulation : 1200 bauds ;
* durée égale des bits à « 0 » et « 1 » ;
* codage par modulation d’amplitude :
    * présence de la porteuse : bit à « 0 » ;
    * absence de la porteuse : bit à « 1 ».

![Oscillogramme de la sortie téléinfo](|filename|/images/teleinfo/teleinfo_modulation.png)

### Encodage

Un caractère est codé sur 10 bits de la manière suivante (§ 1.5) :

* un bit de start correspondant à un « 0 » logique ;
* 7 bits pour représenter le caractère en ASCII ;
* 1 bit de parité, parité paire ;
* un bit de stop correspondant à un « 1 » logique.

### Données

Et enfin, une fois le signal démodulé et décodé, nous obtenons des données texte
lisibles mais incompréhensibles :

    ADCO 130622778433 D
    OPTARIF HC.. <
    ISOUSC 45 ?
    HCHC 032448320
    HCHP 052057919 9
    PTEC HP..
    IINST 001 X
    IMAX 039 K
    PAPP 00170 )
    HHPHC D /
    MOTDETAT 000000 B

Le paragraphe 2 de la norme détaille toutes les informations disponibles selon
le type de compteur. Histoire d’y voir un peu plus clair, voici la traduction de
la trame ci-dessus (il s’agit d’un compteur « bleu » électronique monophasé
multitarif, § 2.4) :

* l’identifiant du compteur ;
* l’option tarifaire (HC pour l’option heures creuses) ;
* l’intensité souscrite (45 A) ;
* l’index de consommation en heures pleines ;
* l’index de consommation en heures creuses ;
* période tarif en cours (heure pleine) ;
* l’intensité instantanée ;
* l’intensité maximale appelée ;
* la puissance apparente ;
* « l'horaire heures pleines/heures creuses (Groupe "HHPHC") est codé par le
  caractère alphanumérique A, C, D, E ou Y correspondant à la programmation du
  compteur » (oui c’est un copier/coller de la norme parce que je n’ai rien
  compris…) ;
* mot d’état du compteur (réservé au distributeur, comprendre que l’on n’aura
  pas plus d’information).

## Réalisation

Voilà pour la théorie. Maintenant nous allons pouvoir brancher le fer à souder…
Façon de parler puisque l’on va commencer par un prototype à base de raspberry.

Celui-ci va être directement branché sur le compteur par l’intermédiaire d’un
circuit qui va s’occuper de la démodulation. Un programme en C va récupérer les
trames pour les insérer dans une base de données. Pour finir une application en
PHP va utiliser cette base pour afficher de beaux graphiques.

### Démodulation

Le but est de transformer un signal électrique en suite de « 0 » et « 1 ».

L’idée géniale qui va grandement nous simplifier la vie vient de
[hd31](http://www.chaleurterre.com/forum/viewtopic.php?t=13232) qui propose
d’utiliser un octocoupleur :

Un oscillogramme vaut mieux qu’un long discours :

![Oscillogramme](|filename|/images/teleinfo/oscillo.png)

Le schéma du circuit est extrêmement simple. Attention toutefois aux
branchements avec le raspberry, les GPIO n’ont aucune protection (réfléchissez
bien avant de connecter de pin 1).

![Circuit](|filename|/images/teleinfo/circuit.png)

### Décodage

Ce circuit va directement nous servir sur le pin 10 du raspberry un signal
RS232.  C’est Linux, via un terminal série, qui va faire tout le reste du
travail.

Par défaut le périphérique représentant le pin 10 (*/dev/ttyama0*) est
configuré comme console série. Il faut donc supprimer les options suivantes
du fichier */boot/cmdline.txt* :

     console=ttyAMA0,115200 kgdboc=ttyAMA0,115200

Et, dans */etc/inittab*, la ligne :

     T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100

Après redémarrage, on configure le port série :

    # stty 1200 cs7 evenp cstopb -igncr -inlcr -brkint -icrnl -opost -isig -icanon
    -iexten -F /dev/ttyAMA0

Et on admire le résultat :

    # cat /dev/ttyAMA0
    INST 012 Z
    IMAX 039 K
    PAPP 02750 /
    HHPHC D /
    MOTDETAT 000000 B
    ADCO 130622778433 D
    OPTARIF HC.. <
    ISOUSC 45 ?
    HCHC 032449500 !
    HCHP 052061818 2
    PTEC HC.. S
    IINST 012 Z
    IMAX 039 K
    PAPP 02740 .
    HHPHC D /
    MOTDETAT 000000 B
    ADCO 130622778433 D
    OPTARIF HC.. <
    ISOUSC 45 ?
    HCHC 032449502 #
    HCHP 052061818 2
    PTEC HC.. S
    IINST 012 Z
    IMAX 039 K
    PAPP 02740 .
    HHPHC D /
    MOTDETAT 000000 B
    ADCO 130622778433 D
    OPTARIF^C

### Donnée

Encore une fois, je n’ai rien inventé, je me suis contenté de reprendre [ce
code](|filename|/files/teleinfo/teleinfo_mysql.c) en C qui va récupérer une trame et la stocker dans une
base MySQL dont l’unique table *teleinfo* a été crée avec le script
[teleinfo.sql](|filename|/files/teleinfo/teleinfo.sql).

On ajoute une entrée dans la crontab pour récupérer les données toutes les
minutes :

    * * * * * /home/pi/teleinfo > /dev/null

### Visualisation

Et pour finir, il nous reste plus qu’à installer une belle interface pour
visualiser les données.

Pour commencer, j’ai choisi une modeste application en PHP :
[teleinfov3](http://penhard.anthony.free.fr/?p=283) distribuée sous forme
d’archive.

![teleinfov3](|filename|/images/teleinfo/teleinfov3.png)

Lorsque j’aurais accumulé plus de capteurs, je me pencherai sur
[ThingSpeak](https://www.thingspeak.com/) mais en attendant teleinfov3 répond
parfaitement à mes besoins.

## Conclusion

Au départ je souhaitais réaliser ce projet avec un arduino et envoyer les données
en ZigBee. Malheureusement mon récepteur semble capricieux, et comme étant très
agacé par l’article d’Open Silicium, j’ai pris ce que j’avais sous la main.

Au final, la mise en place est très simple et je pourrais utiliser cette
plateforme pour agréger d’autres capteurs (consommation d’eau, récupération des
informations d’une station météo, …).

![Le résultat final](|filename|/images/teleinfo/resultat.png)

Malgré tout, si vous aimez la bidouille, je vous conseille de lire Open Silicium
dont la majorité des articles est passionnante.

## Références

* <http://www.chaleurterre.com/forum/viewtopic.php?t=13232>
* <http://hallard.me/gestion-de-la-teleinfo-avec-un-raspberry-pi-et-une-carte-arduipi/>
