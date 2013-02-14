Title: Programmation événementielle en PHP
Date: 2011-06-17 14:34
Tags: PHP

Le paradigme de programmation événementielle semble peut connu, en tout cas
peut utilisé par les développeurs PHP, peut être parce que la gestion des
signaux n'est pas incluse dans le langage, contrairement au C# ou au
Javascript.

Petit manuel explicatif…

Le principe de la programmation événementielle est simple : une entité (dans
notre cas, ce sera un objet) à la possibilité d'envoyer un événement,
généralement suite à une action réalisée, et le développeur est en mesure
d'intercepter cette événement grâce à des fonctions de rappel (*callback* en
anglais) pour y adjoindre un traitement *supplémentaire*. Ce dernier mot est
important, il ne faut pas voir cela comme une solution pour court-circuiter un
traitement mais comme une manière d'effectuer des actions supplémentaires.

Exemple concret : vous souhaitez écrire dans un fichier de log les connexions
ayant échouées, il va vous suffit d'intercepter un signal *login-fail* envoyé
par l'objet gérant l'identification pour écrire une ligne dans un fichier. Par
contre il sera difficile de faire en sorte que système de d'identification
utilise un autre mécanisme pour authentifier les utilisateurs.

Au niveau des inconvénients majeurs de la programmation événementielle : il
faut que les signaux soient prévus par le développeur du cœur et il n'est
généralement pas possible d'ordonner les appels aux fonctions de rappel.

En contre partie, on y gagne en souplesse, en rapidité et couplé à la POO, il
est possible d'ajouter des traitements simplement, sans utiliser l'héritage, et
de conserver ce dernier pour modifier en profondeur un système.

Voici un exemple d'implémentation des signaux en PHP dans le cadre de mon
framework d'expérimentation :

[paste:http://git.homecomputing.fr/?p=nano-mvc.git;a=blob_plain;f=signal.php]

Voici un exemple simple pour comprendre le déroulement des événements :

    <?php

    require_once 'signal.php';

    class Sender
    {
      public function __construct()
      {
        \NanoMvc\Signal::create($this, 'init');
      }

      public function init()
      {
        \NanoMvc\Signal::emit($this, 'init');
      }
    }

    $s = new Sender();

    \NanoMvc\Signal::connect($s, 'init', function() {
      print 'Sender::init';
    });

    $s->init();

Étrangement sur
[Wikipédia](http://fr.wikipedia.org/wiki/Design_pattern#Comportement) cette
technique est classée comme design pattern, je ne pense pas que ce soit le cas,
par contre elle peut être utilisée pour le patron
[observateur](http://fr.wikipedia.org/wiki/Observateur_%28patron_de_conception%29)
qui, étrangement, est directement disponible en PHP grâce aux classes
[SplObserver](http://fr.php.net/manual/fr/class.splobserver.php) et
[SplSubject](http://fr.php.net/manual/fr/class.splsubject.php) ?! Allez savoir
pourquoi…
