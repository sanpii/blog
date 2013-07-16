Title: FPGA for humans
Date: 2013-07-17
Tags: FPGA

Quelque temps après avoir découvert
l’[arduino](decouvrez-lelectronique-libre-avec-larduino.md), et oublié mes
aprioris sur l’électronique, j’ai entendu parlé des
[FPGA](https://fr.wikipedia.org/wiki/FPGA).

Le concept est aussi étrange que passionnant : pouvoir programmer un processeur
pour lui faire accomplir une tâche. Cela peux aller du clignotement de LED (si
vous pensez qu’un raspberry pi ne tue pas assez de bébés chats), à
l’implémentation d’un processeur ARM.

À première vue, on se rapproche du saint Graal du tout open source.
Malheureusement, une fois le joujou reçu, on se rend rapidement compte que le
chemin risque d’être plus long que prévu…

Effectivement en ayant un processeur programmable, on fait un pas en avant avec
la possibilité de publier le code lié à la logique du matériel. Mais entre le
code source et le « programme » injecté dans le FPGA il y a une étape qui va
nous poser de gros problèmes : la synthèse.  Si pour les logiciels il existe des
compilateurs libres, au niveau matériel les suites logiciels sont fermées et
l’ingénierie inverse n’est pas aussi aisée.

Bon les utiliser pourquoi pas, mais de là à ce que ce soit les outils que me
torturent il ne faut pas déconner !

Ayant opté pour un [papilio](http://papilio.cc/) basé sur un [Xilinx
Spartan-3e](http://www.xilinx.com/support/index.html/content/xilinx/en/supportNav/silicon_devices/fpga/spartan-3e.html)
j’ai donc eu le choix d’utiliser
[ISE](http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html),
et c’est à ce moment que j’ai fait un bon de dix ans en arrière quand je jouais
avec *Borland C++ Builder* :

* fermé ;
* fonctionnalités payantes ;
* anti-ergonomique ;
* un monstre à télécharger.

Je suis rapidement tombé sur un
[Makefile](https://github.com/marvin2k/xilinx_makefile) pour xilinx, ce qui m’a
convaincu de faire quelque chose de plus moderne[^1] , basé sur
[waf](https://code.google.com/p/waf/). Après de nombreuses heures à essayer de
comprendre les étapes de la synthèse puis de la simulation (heureusement ISE
affiche toutes les commandes exécutées), je suis enfin arrivé à un résultat
publiable : [xilinx-waf](https://github.com/sanpii/xilinx-waf) !

Afin de comprendre le chemin parcouru, je vous laisse comparer un [projet
d’exemple](https://github.com/sanpii/xilinx-waf-example) avec un
[tutoriel](http://papilio.cc/index.php?n=Papilio.GettingStartedISE).
Hélas je ne peux pas vous épargner le téléchargement et l’installation
d’une licence pour ISE.

Je vais enfin pouvoir entrer dans le monde des FPGA armé de *vim* :)

[^1]: Oui parce qu’avec les autotools, on passe à quelque chose d’ouvert et de
plus léger à télécharger, par contre niveau facilité d’utilisation et
ergonomie, on n’avance pas beaucoup.
