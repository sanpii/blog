Title: re: INI vs JSON vs XML
Date: 2011-03-03 15:09
Tags: PHP, commentaire

Ce billet est en réponse au billet [INI vs JSON vs
XML](http://www.geek-directeur-technique.com/2011/03/03/ini-vs-json-vs-xml).

> «dump» de structures (ceux qui ont fait du C me comprendront)

Mon dieux ! Certains ont finis au bûché pour moins que ça.

Sérieusement, je ne pense pas que le choix d'un format doit se faire sur les
performances de l'analyse sachant que :

* dans la plupart des cas la configuration est chargée une seule fois, au
lancement de l'application ;
* un analyseur (*parser*) ça se change, ça s'améliore sans impact côté
utilisateur.

Mes critères pour choisir un format de fichier de configuration serait plutôt,
par ordre d'importance :

* lecture et modification aisée par un humain ;
* flexibilité du format ;
* existence d'un analyseur, si possible intégré au langage.

À partir de ça, mon choix se résume généralement à :

* ini pour une configuration simple (voir intermédiaire en modifiant
légèrement l'analyseur comme *Zend\_Config\_Ini*) ;
* yaml pour une configuration complexe.

Le Json est devenu presque incontournable en javascript grâce à son support
natif dans le langage mais d'après mon expérience (très mince dans ce domaine),
il est utilisé pour la mise à plat (*serialization*) de données plutôt que pour
la configuration.

Le XML, son seul avantage est la validation par DTD donc il peut être pratique
pour la mise en place de gros fichier de configuration qui doivent être écrit à
la main, comme c'est le cas dans Magento (sauf qu'ils ont juste oubliés les
DTD…) sinon ce format est bien trop verbeux pour être facilement lisible par
une personne.
