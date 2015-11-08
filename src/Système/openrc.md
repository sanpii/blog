Title: Passer à openrc sous Archlinux

Depuis quelque mois, j’ai migré mes PC de bureaux de Debian Sid à Archlinux,
pour essayer autre chose (je m’ennuyai Sid marche trop bien).

C’était l’occasion de tester systemd. Je ne vais pas m’étendre sur ce qui me
déplait dans systemd, libre à vous de l’utiliser mais si vous êtes ici c’est
dans le but de changer de système de démarrage, alors allons y.

Ah juste avant de tout casser, j’ai effectué cette manipulation avec succès sur
trois PC. Par contre j’ai un système minimaliste, je n’ai pas eu besoin de jouer
avec polkit. Bien connaitre votre système est indispensable avant de vous
lancer.

## Openrc

### Installation

L’installation d’openrc en elle même ne pose pas de soucis, il suffit
d’installer — bien évidemment — openrc et également une version modifiée de
sysvinit et les fichiers de services :

```
yaourt -S openrc-git openrc-sysvinit openrc-arch-services-git
```

> ***note*** Il y a un conflit avec le fichier `/usr/bin/runscript` également
> présent dans le paquet minicom. Du coup j’utilise
> [picocom](https://www.archlinux.org/packages/community/x86_64/picocom/).

### Configuration

Commençons par activer les log et l’unicode (sans cette dernière option,
impossible de passer en bépo lors du démarrage). Pour cela, dans
`/etc/openrc/rc.conf` modifiez les deux lignes suivantes :

```
rc_logger="YES"
unicode="YES"
```

Les modules noyau à charger lors du démarrage, avant présent dans le dossier
`/etc/module-load.d` sont à renseigner dans le fichier
`/etc/openrc/conf.d/modules`. Par exemple :

```
modules="loop nfs"
```

Il faut, bien évidemment, réactiver les services :

```
rc-update add alsa default
rc-update add dbus default
rc-update add udev default
```

Au premier redémarrage, j’ai eu la drôle de surprise de ne plus pouvoir utiliser
le clavier ou la souris. Il faut simplement ajouter votre utilisateur aux
groupes adéquates afin d’avoir les bons droits :

```
usermod -a -G video,input,audio sanpi
```

Par défaut, grub utilise toujours systemd comme système d’init. Il faut donc lui
préciser d’utiliser `/usr/bin/init-openrc`. Dans le fichier `/etc/default/grub`
ajoutez :

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet init=/usr/bin/init-openrc"
```

Puis regénérer la configuration de grub :

```
grub-mkconfig -o /boot/grub/grub.cfg
```

Vous pouvez maintenant redémarrer, prévoyez tous de même un système de secours
sur clés usb, au cas où…

Nous venons de remplacer une partie de systemd, à savoir celle en charge de
l’initialisation des services lors du démarrage. Il nous reste encore du travail
avec la gestion du réseau, des log, du bus de communication inter-processus, de
tâches récurentes et des périphériques.

![Systemd gluttony animation](|filename|/images/systemd.gif)

## Network

Openrc fourni
[newnet](https://github.com/funtoo/openrc/blob/master/README.newnet), nous avons
juste à supprimer les paquets inutils :

```
pacman -Rsn netctl openresolv
```

Normalement le service dhcpcd est activé par défaut.

## Syslog

Pour retrouver des logs, rien de très compliqué :

```
yaourt -S syslog-ng-nosystemd
rc-update add syslog-ng default
```

## D-BUS

Idem pour dbus :

```
yaourt -S dbus-nosystemd
rc-update add dbus default
```

## Cron

Je pense que vous avez compris maintenant :

```
yaourt -S cronie
rc-update add cronie default
```

## Udev

Enfin, pour udev, c’est un peu plus long car il y a un souci de dépendances.
Nous allons donc devoir recompiler deux paquets.

Commençons par lancer l’installation au travers de `yaourt` afin qu’il installe
les dépendances nécessaires :

```
yaourt -S eudev eudev-systemdcompat
```

Il est inutile de lancer la compilation, nous allons le faire avec `makepkg` :

```
git clone https://aur.archlinux.org/eudev.git
cd eudev
makepkg -d
mv perso.db.tar.gz eudev/eudev-3.1.2-4-x86_64.pkg.tar.xz ..
```

Pour le paquet `eudev-systemdcompat`, il faut commencer par éditer le fichier
PKGBUILD afin de mettre à jour la version de systemd, puis on lance la
compilation :

```
git clone https://aur.archlinux.org/eudev-systemdcompat.git
cd eudev-systemdcompat
vi PKGBUILD
makepkg -d
mv eudev-systemdcompat/eudev-systemdcompat-224-1-x86_64.pkg.tar.xz ..
```

Ensuite, nous créons un [dépôt
local](https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#Custom_local_repository)
auquel on ajoute nos deux paquets :

```
cd ..
repo-add perso.db.tar.gz eudev-3.1.2-4-x86_64.pkg.tar.xz
repo-add perso.db.tar.gz eudev-systemdcompat-224-1-x86_64.pkg.tar.xz
```

Dans `/etc/pacman.conf`, on ajoute notre nouveau dépôt :

```
[perso]
SigLevel=never
Server=file:///home/sanpi
```

Et on lance l’installation :

```
sudo pacman -Sy eudev eudev-systemdcompat
```

Avant de redémarrer, n’oubliez pas de modifier le fichier
`/etc/openrc/init.d/udev` pour lancer la bonne commande, à savoir
`/usr/bin/udevd`.

## Conclusion

Après plusieurs mois d’utilisation, le seul souci que j’ai avec openrc vient
des fichiers de services. Puisqu’ils ne sont pas fournit par archlinux, il faut
les trouver ailleurs. Il en existe beaucoup dans
[aur](https://aur.archlinux.org/packages/?K=-openrc), mais ils ne semblent plus
maintenus (impossible de les installer pour une sombre histoire de somme de
contrôle). Du coup, généralement je récupère la source (issue de gentoo) et je
les modifie manuellement.
