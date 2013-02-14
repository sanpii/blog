Title: Les design patterns, une question de langage ?
Date: 2011-06-10 15:24
Tags: PHP, Design pattern

Je vais tenter de m'expliquer sur ce que j'ai dit hier, à savoir :

> les design patterns sont des concepts abstrait, liés à aucun langage, par
conséquent un design pattern peut être parfaitement adapté à un langage mais
contre productif avec un autre.

Un patron de conception, comme son nom l'indique est lié à la conception d'un
logiciel, en amont de la phase de développement, par conséquent le langage
utilisé ne devrait pas influencer les choix. Ne devrait pas ne signifie pas que
ce n'est pas le cas.

Premier point, les design patterns sont une solution à des problèmes en
utilisant le paradigme objet. Pour ceux qui souhaitez s'exercer au design
patterns en C, en SQL ou en Lisp : ce n'est pas une bonne idée. Pas que ce soit
impossible, mais il faudra commencer par développer une couche objet pour le
langage.

Second point, même en restant dans les langages objet, ils ne possèdent pas
tous les mêmes fonctionnalités. Je trouve, par exemple, que la
[fabrique](http://fr.wikipedia.org/wiki/Fabrique_%28patron_de_conception%29)
perd beaucoup de sont intérêt lorsque le langage n'est pas capable d'instancier
un nom de classe dynamique, ou encore les [fonctions de
rappel](http://en.wikipedia.org/wiki/Callback_%28computer_programming%29) en
l'absence de pointeur de fonction.

Mais le problème peut (devrait ?) aussi être pris dans l'autre sens : je
conçois de faire une application web avec une architecture MVC, est-ce une
bonne idée de développer un CGI en C ?

Avant de nous laisser troller^Wdiscuter, pensez à l'implémentation du pattern
[Null Object](http://en.wikipedia.org/wiki/Null_Object_pattern) en C :

    :::c
    free(p), p = NULL;

Edit : <http://c2.com/cgi/wiki?AreDesignPatternsMissingLanguageFeatures>, merci
à [Eric](http://zenprog.com/) pour son apport à la discussion.
