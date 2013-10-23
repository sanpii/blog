Title: Découvrez l’électronique libre avec l’Arduino
Date: 2010-07-07 23:49
Tags: Libre, Électronique, Arduino

Si on parle souvent de logiciels libre, il n’y a pas que les logiciels qui
peuvent l’être, le matériel aussi, tout du moins les spécifications. Vous
connaissez peut-être déjà [Openmoko](http://www.openmoko.org) : le téléphone
portable libre, [Open Graphics Project](http://www.opengraphics.org) : une carte
graphique libre. Aujourd’hui nous allons découvrir
[Arduino](http://www.arduino.cc/) : la plateforme de développement électronique
libre !

Qu’est ce qu’une plateforme de développement électronique ? C’est un circuit
comprenant un microcontroleur que vous allez pouvoir relier, d’un côté, à votre
ordinateur pour le programmer, et d’un autre côté à un circuit électronique afin
de faire interagir votre programme avec le monde réel. Parce que c’est surtout
ça l’Arduino : une passerelle entre les mondes virtuel et réel !

![Arduino](|filename|/images/arduino.jpg)

L’avantage de l’Arduino est d’être très simple à utiliser, en particulier pour
les personnes qui n’y connaissent rien en électronique, puisque l’on travail sur
une plaque de développement sans soudure : il suffit de déposer les composants
sur la plaque et la programmation (en C++) est simplifiée à l’aide d’un ensemble
de bibliothèques qui vous affranchies des contraintes techniques.

Voici par exemple un programme qui fait clignoter une LED en C en utilisant
uniquement les bibliothèques AVR :

    :::C
    #include <stdlib.h>
    #include <avr/io.h>
    #include <util/delay.h>

    int main (void)
    {
      DDRB = 0b10000000;

      while (1)
      {
        PORTB = 0xFF;
        _delay_ms (1000);
        PORTB = 0x00;
        _delay_ms (1000);
      }

      return 1;
    }

Si le code n’est pas très compliqué (à la hauteur de son utilité), on voit que
l’on ai très proche de la machine. Voici la même chose en version *Arduino* :

    :::C
    int ledPin =13;

    void setup ()
    {
      pinMode (ledPin, OUTPUT);
    }

    void loop ()
    {
      digitalWrite (ledPin, HIGH);
      delay (1000);
      digitalWrite (ledPin, LOW);
      delay (1000);
    }

C’est quand même beaucoup plus compréhensible, sans parler de la compilation…
Si justement, en parlant de compilation, il existe un IDE Arduino qui vous
permet de compiler et d’uploader votre programme très simplement.

Comme je vous le disais en introduction, le projet est libre aussi bien les
spécifications de l’Arduino lui même que son bootloader, ceci permet de voir
énormément d’initiatives autour en particulier les *shields* qui sont des
circuits à fixer sur l’Arduino pour l’étendre (connexion ethernet, wifi, …).

Pour vous faire une idée, vous pouvez parcourir la [liste des
tutoriels](http://arduino.cc/en/Tutorial/HomePage) ou encore l’un des PDF livré
avec les kit de démarrage, par exemple celui de Adafruit : [Experimenter’s
Guide](http://ardx.org/src/guide/2/ARDX-EG-ADAF-WEB.pdf).

Si vous souhaitez vous lancer il existe de nombreux kit de démarrage comprenant
l’Arduino ainsi que divers composants permettant de réaliser ses premiers
circuits. Vous pouvez lire un aperçu d’un certain nombre de kit : [partie
1](http://aaroneiche.com/2009/06/29/arduino-starter-rundown/) et [partie
2](http://aaroneiche.com/2009/07/16/arduino-starter-rundown-part-2/).
Personnelement j’ai pris celui de
[EarthshineelEctronics](http://www.earthshineelectronics.com/10-arduino-duemilanove-compatible-starter-kit.html)
pour la diversité des composants (on peut en faire un
[pong](http://blog.bsoares.com.br/arduino/ping-pong-with-8x8-led-matrix-on-arduino)),
l’adaptateur secteur et le prix.

J’espère vous avoir donné envie de jouet avec ce petit bijou, et si cela ne vous
suffit pas, je vous promet de vous présenter un projet super geek, une fois que
j’aurais reçu les composants…
