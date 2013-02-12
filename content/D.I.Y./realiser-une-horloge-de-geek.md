Title: Réaliser une horloge de geek
Date: 2010-08-02 17:02
Tags: Électrique, Arduino, horloge

Je vous l’avez promis dans mon [premier article sur
l’arduino](decouvrez-lelectronique-libre-avec-larduino.md),
il est enfin terminé : mon premier projet utilisant l’arduino !

Je vous propose donc de construire votre propre horloge, pourquoi geek ? Tout
simplement parce que l’heure sera affichée à l’aide de LED sous forme binaire.

Pour commencer, j’ai repris
l’[HorlogeUltraBinaire](http://www.lagrottedubarbu.com/2009/12/30/lagrottedubarbu-saison-02-episode-06-horlogeultrabinaire/)
de la grotte du barbu qui se compose de 13 LED (4 pour les heures, 6 pour les
minutes et 3 pour les secondes) et de 13 résistances. Vous pouvez déjà commencer
par réaliser ce projet pour comprendre le principe de base.

Le but étant de créer une vraie horloge, il nous faut en plus :

* Une horloge interne temps réel, une rapide recherche sur le site de
l’[arduino](http://arduino.cc/) nous permet de trouver un module RTC DS1307 ;
* Deux boutons pour régler les heures et les minutes.

Par chance, il existe des modules RTC complet (DS1307 + cristal + condensateur +
pile) qui va nous éviter de griller ces composants sensibles lors de nos
premiers coup de fer à soudure.

Pour rentabiliser les frais de ports, j’ai tout commandé sur le même site, mis à
part l’arduino et le module RTC, les composants peuvent se trouver facilement.

* [1 arduino](http://www.sparkfun.com/commerce/product_info.php?products_id=666) ;
* [1 module RTC](http://www.sparkfun.com/commerce/product_info.php?products_id=99) ;
* [1 plaque proto](http://www.sparkfun.com/commerce/product_info.php?products_id=8619) ;
* [4 LED vertes](http://www.sparkfun.com/commerce/product_info.php?products_id=9592) ;
* [6 LED jaunes](http://www.sparkfun.com/commerce/product_info.php?products_id=9594) ;
* [3 LED rouges](http://www.sparkfun.com/commerce/product_info.php?products_id=9590) ;
* 15 résistances de 150 Ohm ;
* [2 boutons poussoir](http://www.sparkfun.com/commerce/product_info.php?products_id=9190), bien épais pour qu’il traverse la paroi de la boite ;
* [1 support pour les piles](http://www.sparkfun.com/commerce/product_info.php?products_id=9835) ;
* un boitier.

Coût total : 55.53€ (+9.03€ de frais de port).

Avant de commencer à souder il faut bien réfléchir à ceux que nous allons faire
(le control+Z n’est pas au point en électronique). Pour poser mes idées à plat,
après quelques gribouillis sur une feuille de papier, j’ai utilisé le logiciel
[fritzing](http://fritzing.org/) encore jeune mais parfaitement utilisable et
remplace très bien [eagle](http://www.cadsoft.de/).

Nous commençons donc par réaliser notre projet sur une platine de développement
sans soudure :

![Schéma plateforme de dev.](|filename|/images/8clockbb.png)

Le composant mystère représentant notre module RTC.

Si vous souhaitez tester tout de suite, le code source est disponible en fin
d’article.

Donc voici le résultat :

![Plateforme de dev.](|filename|/images/dsc00029.jpg)

Ensuite, il faut réaliser la vue schématique, une fonction d’auto-routage permet
de relier automatiquement les composants entre eux, mais il vaut mieux commencer
par bien les organiser et, pour avoir quelque chose de propre, modifier les
routes crées à la main.

![Schéma](|filename|/images/8clocksche.png)

Pour finir, nous pouvons créer notre plan pour circuit imprimé, même si vous ne
souhaitez pas le réaliser, le placement des composants sur une platine d’essais
est identique.

![Schéma PCB](|filename|/images/8clockpcb.png)

Le module RTC n’est pas représenté car connecté directement à l’arduino. Je vous
conseil également de prévoir des [connecteurs
mâles](http://www.sparkfun.com/commerce/product_info.php?products_id=117) pour y
relier les LED et ensuite fixer l’arduino dessus, à la manière d’un shield (sauf
que je me suis rendu compte de ce problème trop tard et je n’est pas trouvé de
place pour mettre une seconde rangée de connecteurs).

Pour finir voici quelques photo du résultat final :

![](|filename|/images/dsc00032.jpg)
![](|filename|/images/dsc00033.jpg)
![](|filename|/images/dsc00031.jpg)
![](|filename|/images/dsc00030.jpg)

J’ai utilisé la boite en carton reçue avec mes composants mais ce n’est que
temporaire, j’ai prévu une belle boîte en plastique pour contenir le tout.

Pour conclure et avant de vous laisser tomber dans les mêmes pièges que moi,
voici quelques points d’améliorations, du plus important ou moins important :

* créer un shield, ça simplifie la connections à l’arduino ;
* utiliser un circuit imprimé, le plus pénible étant de créer la masse,
actuellement j’ai un faux contact à ce niveau (sûrement une soudure mal faite
qui ne conduit pas le courant), heureusement la prise USB de l’arduino touche la
masse (et pas autre chose…) et permet au circuit de fonctionner ;
* créer mon propre module RTC et un [arduino
standalone](http://www.arduino.cc/en/Main/Standalone), cela permet de tout
mettre sur un circuit imprimé et réduire les coûts ;
* utiliser deux registres à décalage 74HC595 pour éviter de monopoliser les 13
entrées digitales de l’arduino pour, par exemple, afficher la date sur un écran
LCD (parce qu’en binaire, ça ne va pas être évident…).

Voici le code modifié pour récupérer l’heure via le module RTC et prendre en
compte l’appuis sur les boutons :

    :::C++
    #include <WProgram.h>
    #include <Wire.h>
    #include <DS1307.h>

    static void add_hour ()
    {
      int hour = RTC.get (DS1307_HR, true);
      RTC.stop ();
      RTC.set (DS1307_HR, (hour + 1) % 12);
      RTC.start ();
    }

    static void add_minute ()
    {
      int minute = RTC.get (DS1307_MIN, true);
      RTC.stop ();
      RTC.set (DS1307_MIN, (minute + 1) % 60);
      RTC.set (DS1307_SEC, 0);
      RTC.start ();
    }

    void setup ()
    {
      for (int i = 1; i <= 13; i++)
      {
        pinMode (i, OUTPUT);
      }
      Serial.begin (9600);
    }

    void loop ()
    {
      int reste;

      if (analogRead (1) > 500)
      {
        add_hour ();
        while (analogRead (1) > 500)
        {
        }
        return;
      }

      if (analogRead (0) > 500)
      {
        add_minute ();
        while (analogRead (0) > 500)
        {
        }
        return;
      }

      int hour = RTC.get (DS1307_HR, true);
      int minute = RTC.get (DS1307_MIN, false);
      int second = RTC.get (DS1307_SEC, false);

      Serial.println (hour);
      //calcul des heures
      reste = hour;
      if ((reste / 8) >= 1)
      {
        digitalWrite (13, HIGH);
        reste = reste % 8;
      }
      else
      {
        digitalWrite (13, LOW);
      }
      if ((reste / 4) >= 1)
      {
        digitalWrite (12, HIGH);
        reste = reste % 4;
      }
      else
      {
        digitalWrite (12, LOW);
      }
      if ((reste / 2) >= 1)
      {
        digitalWrite (11, HIGH);
        reste = reste % 2;
      }
      else
      {
        digitalWrite (11, LOW);
      }
      if ((reste / 1) >= 1)
      {
        digitalWrite (10, HIGH);
        reste = reste % 1;
      }
      else
      {
        digitalWrite (10, LOW);
      }

      //calcul des minutes
      if (minute / 32 >= 1)
      {
        digitalWrite (9, HIGH);
        reste = minute % 32;
      }
      else
      {
        digitalWrite (9, LOW);
        reste = minute;
      }
      if (reste / 16 >= 1)
      {
        digitalWrite (8, HIGH);
        reste = reste % 16;
      }
      else
      {
        digitalWrite (8, LOW);
      }
      if (reste / 8 >= 1)
      {
        digitalWrite (7, HIGH);
        reste = reste % 8;
      }
      else
      {
        digitalWrite (7, LOW);
      }
      if (reste / 4 >= 1)
      {
        digitalWrite (6, HIGH);
        reste = reste % 4;
      }
      else
      {
        digitalWrite (6, LOW);
      }
      if (reste / 2 >= 1)
      {
        digitalWrite (5, HIGH);
        reste = reste % 2;
      }
      else
      {
        digitalWrite (5, LOW);
      }
      if (reste / 1 >= 1)
      {
        digitalWrite (4, HIGH);
        reste = reste % 1;
      }
      else
      {
        digitalWrite (4, LOW);
      }

      //calcul des secondes
      if (second < 30)
      {
        digitalWrite (2, HIGH);
        digitalWrite (3, LOW);
      }
      else
      {
        digitalWrite (2, LOW);
        digitalWrite (3, HIGH);
      }
      if (second % 2 == 0)
      {
        digitalWrite (1, LOW);
      }
      else
      {
        digitalWrite (1, HIGH);
      }
    }

N’hésitez pas à poster vos réalisations, améliorations (c’est mon premier projet
d’électronique) ou vos questions ;)
