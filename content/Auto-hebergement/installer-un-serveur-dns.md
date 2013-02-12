Title: Installer un serveur DNS
Date: 2010-09-15 07:45
Tags: Debian, Libre, dns

Continuons à peupler notre morceau d’internet grâce à la mise en place de notre
propre serveur DNS.

Avant de vous lancer dans la partie technique, je vous conseille de (re)voir le
rôle d’un serveur DNS grâce à l’article de Spyou : [Internet, basé sur un énorme
annuaire](http://blog.spyou.org/wordpress-mu/2010/05/10/internet-base-sur-un-enorme-annuaire-6/).

Pour commencer, nous allons installer le serveur DNS bind9 :

    :::bash
    # apt-get install bind9

Vous pouvez aussi installer les outils de test sur votre PC de bureau :

    :::bash
    # apt-get install dnsutils

Vous pouvez dés à présent tester votre serveur DNS (remplacez 192.168.51.4 par
l’adresse de votre serveur) :

    :::bash
    $ dig @192.168.51.4 google.fr

Maintenant la partie la plus intéressante (comprendre qu’il ne s’agit plus
simplement d’installer un paquet), consiste à nous déclarer comme étant le
serveur faisant autorité pour les noms de domaines que vous possédez.

Pour commencer, dans le fichier */etc/bind/named.conf.local*, nous allons
déclarer une nouvelle zone :

    zone "homecomputing.fr" {
      type master;
      file "homecomputing.fr.zone";
      allow-transfer { 174.37.196.55; };
      also-notify { 174.37.196.55; };
    };

Nous nous définissons donc comme le serveur maître pour la zone
*homecomputing.fr* (je vous conseille de le remplacer par votre nom de domaine
si vous souhaitez toujours accédez à mon site…), la configuration de la zone
se trouve dans le fichier *homecomputing.fr.zone* (le répertoire par défaut
correspond à l’option *directory* dans le fichier
*/etc/bind/named.conf.options*, c’est à dire */var/cache/bind* sous Debian
Lenny) et les deux dernières options permettent, respectivement, d’autoriser le
transfert de zone et la notification pour notre DNS secondaire (j’y reviendrai
par la suite).

Nous devons ensuite créer notre fichier de zone, */var/cache/bind/homecomputing.fr.zone* :

    $TTL 86400
    @           IN  SOA ns postmaster (2010091508 86400 3600 3600000 86400)
    @               NS     ns
    @               NS     ns2.afraid.org.
    ns              A      82.247.127.96
                    A      82.247.127.96
    *               A      82.247.127.96
    www             CNAME  homecomputing.fr.
    mail            A      82.247.127.96
    @               MX 1   mail
           600  IN  TXT    "v=spf1 a mx ~all"

Rien de très compliqué ici, j’ai en grande partie recopié les paramètres DNS de
mon registrar :

* on commence par définir la durée de vie de nos données en cache en seconde,
ici 1 journée ;
* on défini notre zone :
    * *@* est un synonyme pour le nom de la zone ;
    * *IN* pour une zone internet ;
    * *SOA*, le type de l’enregistrement ;
    * *ns* étant le préfixe du serveur DNS. Vous pouvez aussi précisez l’adresse
complète : *ns.homecomputing.fr.* (sans oublier le point final) ;
    * *postmaster*, l’adresse mail du responsable, ou
*postmaster.homecomputing.fr.* (le premier point étant considéré comme le
caractère @) ;
    * *2010091508*, un numéro de série unique à incrémenter à chaque
modification (souvent de la forme YYYYMMDDxx) ;
    * *86400*, le temps de rafraîchissement ;
    * *3600*, le temps entre deux essais ;
    * *3600000*, le temps d’expiration ;
    * *86400*, la TTL minimum.

Ensuite viennent des enregistrements plus classiques :

* les serveurs DNS faisant autorité sur le domain ;
* les correspondances entre les préfixes et l’IP du serveur. *ns* et *mail*
étant explicitement nommés dans le fichier, ils doivent apparaître, pour le
reste j’envoie tout sur mon seul et unique serveur (c’est le serveur web qui
fait le trie) ;
* un enregistrement *MX* pour la gestion des mails, et *spf* qui permet de
vérifier le nom de domaine d’un expéditeur (pour réduire le spam).

Si notre configuration est terminée, je ne vous ai toujours pas parler du DNS
secondaire. Il s’agit d’un second serveur DNS qui va répliquer votre zone et
prendre le relais en cas de panne de votre serveur. Ce n’est pas une option,
ceci est défini dans une RFC ! Il existe un certain nombre d’entités qui
proposent ce service gratuitement : [fournisseurs de serveurs
secondaires](http://wiki.auto-hebergement.fr/dokuwiki/coop%C3%A9ration/serveur_de_noms_secondaire#fournisseurs_de_serveurs_secondaires),
le seul dont j’ai compris le fonctionnement étant
[FreeDNS](http://freedns.afraid.org/). Si vous en préférez un autre, n’oubliez
pas de modifier l’option *also-notify* et *allow-transfert* dans le fichier
*/etc/bind/named.conf.local* et le champ *ns* de votre zone.

Voilà, vous êtes prêt à gérer votre nom de domaine. Vous pouvez vérifier votre
configuration grâce à l’outils
[ZoneCheck](http://www.afnic.fr/outils/zonecheck/form) de l’AFNIC, si vous avez
bien suivi cet article, vous ne devriez pas avoir d’erreur (j’obtiens simplement
trois avertissements pour non réponse au ping et "incoherence entre le nom
correspondant à l’adresse IP et celui du serveur" - si quelqu’un à une idée de
la signification de cette dernière).

Si tout est ok, vous pouvez déclarer aux DNS qui gère le *.fr* que vous gérer le
domaine *homecomputing.fr* et non plus votre registrar. Chez OVH, il faut aller
dans le menu Accueil > Mutualisé > Domaines & DNS > Serveurs DNS.
