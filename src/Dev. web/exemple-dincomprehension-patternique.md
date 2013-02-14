Title: Exemple d'incompréhension patternique
Date: 2011-06-09 11:08
Tags: PHP, Design pattern

Ah les design pattern, la [dernière fois que je les ai
évoqués](|filename|ajouter-une-methode-a-une-classe-sans-utiliser-lheritage-en-php.md)
c'était pour ne pas en parler, aujourd'hui nous allons donc démontrer (si
c'était encore nécessaire) combien
[Gerald](http://www.croes.org/gerald/blog/nutilisez-pas-les-design-patterns-en-php/109/)
à raison (au moins à ce sujet).

Tout commence ce matin, en buvant mon thé, avec la lecture de [Le Design
Pattern Flyweight (Poids
mouche)](http://blog.lepine.pro/architecture/le-design-pattern-flyweight-poids-mouche)
de [Jeff](http://blog.lepine.pro/author/jeff).

Il faut bien comprendre que les design patterns sont des concepts abstrait,
liés à aucun langage, par conséquent un design pattern peut être parfaitement
adapté à un langage mais contre productif avec un autre.

C'est probablement le cas ici, PHP gére la mémoire automatiquement et il le
fait sûrement mieux que nous. De manière plus généralement, la thése défendue
ce jour sera :

> Quand j'utilise un langage de haut niveau, je lui fait confiance pour la
gestion des tâches ingrates.

Le problème est détectable à la simple lecture du code, puisque dans la boucle
*foreach*, au lieu d'utiliser directement la variable *$oProduct*, on crée un
nouvel objet pour la manipuler, donc on ajoute en mémoire un objet mais plus
gênant on va augmenter le temps de traitement.

Exemple :

    <?php

    $bgtime=time();

    $data = range(1, $argv[1]);

    foreach($data as $d)
    {
      fprintf(STDERR, $d);
    }

    echo 'Memory: '. memory_get_usage() . "\n";
    echo '  real: '. memory_get_usage(true) . "\n";
    echo 'Time: '. (time()-$bgtime) . "\n";
.

    <?php

    class Fly
    {
        private $_data;

        public function hydrate($data)
        {
            $this->_data = $data;
        }

        public function __toString()
        {
            return (string)$this->_data;
        }
    }

    $bgtime=time();

    $data = range(1, $argv[1]);
    $p = new Fly();

    foreach($data as $d)
    {
        $p->hydrate($d);
        fprintf(STDERR, $p);
    }

    echo 'Memory: '. memory_get_usage() . "\n";
    echo '  real: '. memory_get_usage(true) . "\n";
    echo 'Time: '. (time()-$bgtime) . "\n";

Le résultat :

    :::bash
    % php index_fly.php 1000000 2> /dev/null
    Memory: 108523656
      real: 109051904
    Time: 25
    % php index.php 1000000 2> /dev/null
    Memory: 108518952
      real: 109051904
    Time: 10

C.Q.F.D.

Edit : une explication correcte du [design pattern poids mouche en
PHP](http://www.croes.org/gerald/blog/le-poid-mouche-flyweight-en-php/).

PS : le problème est similaire avec l'utilisation de l'[opétateur
+](http://blog.lepine.pro/php/astuces-php-union-de-deux-tableaux-plus-pratique-et-rapide-quun-array_merge),
à inciter le lecteur à gagner quelques microsecondes, Jeff a juste oublié de
préciser la grande différence entre *array_merge* et l'opérateur + : la gestion
des clés en doublons. Je vous laisse découvrir le genre de bug auquel vous
risquez d'être confronté en utilisant aveuglement ce conseil :

    <?php

    $a1 = array('a', 'b', 'c');
    $a2 = array('d', 'e', 'f');
    var_dump(array_merge($a1, $a2));
    var_dump($a1 + $a2);
