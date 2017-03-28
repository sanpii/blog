Title: Ce que qui me dérange dans symfony
Tags: PHP, symfony
Date: 2017-03-08 12:01:03
image: /images/header/symfony.png

Hier, j’ai eu l’occasion de commencer une discussion sur ce que je n’aimai pas
dans symfony. La discussion ayant rapidement dérivé, je n’ai finalement abordé
qu’un seul point. Je vais donc prendre le temps de compléter ma réponse ; cela
me permettra également d’avoir internet sous la main pour référence[^1].

Petite précision : il ne sera en fait question du [symfony standard
edition](https://github.com/symfony/symfony-standard). Symfony fonctionnant par
composant, si l’un d’entre eux ne me convient pas, il suffit de ne pas
l’utiliser (c’est le cas de doctrine ou des annotations). Et de manière
générale, je trouve le cœur de symfony très bien fait.

J’ai aussi fait le choix de ne pas utiliser l’édition standard de symfony, mais
étant le standard de fait (c’est celui utilisé dans la
[documentation](https://symfony.com/doc/master/setup.html#creating-symfony-applications-with-composer))
et étant proposé par d’organisation *symfony* cela lui donne automatiquement
l’étiquette de bonne pratique. Or il y a quelques points qui me posent problème,
en particulier lorsqu’il s’agit d’applications à fort trafic.

## bootstrap.php.cache

Il s’agit d’un fichier présent dans le répertoire `var/` et long de 1300 lignes.
Ce fichier regroupe 5 classes du composant
[HttpFoundation](https://github.com/symfony/http-foundation) et 1 classe de
[ClassLoader](https://github.com/symfony/class-loader)[^2]. Ceci dans le but
d’améliorer les performances en limitant le nombre d’entrées/sorties[^3].

Je comprends l’idée, mais premièrement est-ce le rôle du développeur PHP de gérer
ce genre de chose ? Je ne pense pas. Et deuxièmement, pour quel gain ? 6
fichiers sont agrégés, mais le projet, une fois les dépendances installées en
contient plusieurs milliers !

Plutôt que de faire des estimations à la louche, j’ai ajouté deux lignes dans le
fichier `web/app.php` fraîchement installé, afin d’afficher les statiques
d’entrée/sortie :

```php
$pid = getmypid();
echo file_get_contents("/proc/$pid/io");
```

On vide les différents caches[^4] :
```
sync
echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches
```

Puis on appelle notre page sans le `bootstrap.php.cache` :

```
$ curl http://localhost:8080/app.php | tail -7
rchar: 225933
wchar: 1296
syscr: 329
syscw: 21
read_bytes: 5922816
write_bytes: 0
cancelled_write_bytes: 0
```

Puis avec :

```
$ curl http://localhost:8080/app.php | tail -7
rchar: 220851
wchar: 1234
syscr: 317
syscw: 20
read_bytes: 2940928
write_bytes: 0
cancelled_write_bytes: 0
```

La valeur qui m’intéresse ici est `syscr` qui correspond au nombre d’appel
système `read()` effectué (grossièrement le nombre de fichiers ouverts)[^5]. On
passe de 329 à 317.

Je n’ai pas d’expérience concernant l’administration de machine devant supporter
de fort trafic, mais j’ai le sentiment que ce ne sont pas 4 % d’entrées/sorties
en moins que vont changer quelque chose.

Par contre, pour avoir eu des erreurs provenant de ce fichier (à mes débuts avec
symfony avec la version 2.0), c’est extrêmement pénible à déboguer.

Comme l’indique la documentation, il me semble plus judicieux de jouer sur les
paramètres du cache d’opcode
([opcache.revalidate-freq](https://secure.php.net/manual/en/opcache.configuration.php#ini.opcache.revalidate-freq)
et
[opcache.validate_timestamps](https://secure.php.net/manual/en/opcache.configuration.php#ini.opcache.validate-timestamps)),
vu que vu gérez vos déploiements proprement avec un dossier par version et un
lien `current` qui pointe vers la version publiée, un fichier modifié aura un
chemin différent et sera donc un nouveau fichier pour le cache.

En écrivant cette partie, je viens de m’apercevoir que le fichier sera inclus (dans
la version 3.3 de symfony ?) uniquement pour les versions de PHP antérieures à
7.0 : <http://github.com/symfony/symfony-standard/blob/master/web/app.php#L7>

## Autoloader

Bon après ce gros pavé, un petit pour se reposer. L’édition standard ajoute un
[autoloader de
classes](https://github.com/symfony/symfony-standard/blob/3.2/app/autoload.php)
qui, bien évidement, appelle celui de composer mais en plus appelle une classe
`AnnotationRegistry` issue de doctrine. N’utilisant ni l’un ni l’autre je n’ai
aucune raison de le garder.

De plus, il est désormais possible de le supprimer, une
[PR](https://github.com/symfony/symfony-standard/pull/1056) est ouverte.

## AppCache

La classe
[AppCache](https://github.com/symfony/symfony-standard/blob/3.2/app/AppCache.php)
est un décorateur pour la kernel HTTP à activer dans le fichier
[app.php](https://github.com/symfony/symfony-standard/blob/3.2/web/app.php#L15).

Il s’agit d’un [cache HTTP](https://symfony.com/doc/current/http_cache.html)
comme il en existe d’autres (varnish, squid et même nginx), dans ce cas pourquoi
vouloir le refaire en PHP ? Encore une fois est-ce le rôle d’un développeur PHP
de gérer ce genre de chose ?

## Environnement test

L’édition standard propose trois variantes de configuration nommées *dev*,
*prod* et *test*. Pour les deux premiers, cela me semble inévitable pour activer
le *web profiler*, mais pourquoi *test* ? Instinctivement, je dirais pour
l’environnement de test automatisé. Mais quand je teste mon application, je
souhaite tester ce qui ira en production.

Surtout que cette configuration est basée sur *dev*, je vais donc tester
l’environnement sur lequel les développeurs ont passés leurs journées,
d’expérience il est fort probable que l’environnement de *prod* soit bancal (un
paramètre présent dans `config_dev.yml` qui devrait être dans `config.yml`, par
exemple).

## app_dev.php

Dernier point qui me dérange, c’est cette histoire de double point d’entrée,
[`app.php`](https://github.com/symfony/symfony-standard/blob/3.2/web/app.php) et
[`app_dev.php`](https://github.com/symfony/symfony-standard/blob/3.2/web/app_dev.php).

Outre le léger code dupliqué (passé l’initialisation du projet, il est peu
probable que l’on est à modifier ces fichiers), si l’on suit les conseils de [12
factors](https://12factor.net/fr/config), ce choix devrait se faire via les
variables d’environnement.

Gros avantage de cette méthode, l’outil console sera automatiquement configuré
selon la plateforme, l’option `--env` devient inutile.

Encore une fois, bonne surprise, la discussion est en cours pour utiliser le
nouveau composant
[dotenv](https://symfony.com/blog/new-in-symfony-3-3-dotenv-component) :
<https://github.com/symfony/symfony-standard/issues/1049>.

## Conclusion

En écrivant ce billet, j’ai pu découvrir qu’il y avait déjà des modifications
qui aller dans le sens de mes critiques et d’autres encore en discussions.

Le pendant de cela est qu’il me semble indispensable pour un développeur
symfony, de suivre les modifications de l’édition standard et mettre à jour ses
applications en conséquence, ce qui peut être pénible (un outil permettant de
faire un diff sur trois fichiers rendra les choses moins pénibles). Et bien
évidemment resté critique sur les outils que l’on utilise mais cela me semble
tellement évident…

J’ai agrégé toutes ces modifications dans un projet symfony perso,
[symbiose](https://github.com/sanpii/symbiose) qui est surtout né pour avoir un
squelette symfony et pomm.

Je serais évidemment ravi de discuter de cela sur
[diaspora](https://framasphere.org/people/3a8a1f5092e201339dab2a0000053625) ou
via[^6] [twitter](https://twitter.com/sanpi_).

[^1]: j’ai beaucoup de mal à affirmer quelque chose sans référence, ce qui peut
donner l’impression que je ne suis pas sûr de moi.
[^2]: <https://github.com/sensiolabs/SensioDistributionBundle/blob/master/Composer/ScriptHandler.php#L242>
[^3]: <https://symfony.com/doc/master/performance.html#use-bootstrap-files>
[^4]: <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/sysctl/vm.txt#n191>
[^5]: <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/proc.txt#n1523>
[^6]: Oui, **via** twitter, car il va être difficile de caler un argumentaire
correct en 140 caractères.
