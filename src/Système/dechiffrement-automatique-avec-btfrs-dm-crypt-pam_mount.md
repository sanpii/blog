Title: Déchiffrement automatique avec btfrs, dm-crypt et pam_mount
Date: 2015-08-03 20:03:07
Tags: cryptographie

Ce n’est pas la première fois que je chiffre mes disques durs, mais j’avais
abandonné l’idée par flemme d’insérer une clé usb contenant le fichier clé à
chaque démarrage. La loi sur le renseignement m’a poussé à chercher une autre
méthode (sans mot de passe supplémentaire et sans clé usb).

J’ai donc besoin de déchiffrer deux partitions en RAID1[^1] avec deux clés
différentes (chiffrer deux contenus identiques avec la même clé, je ne sais pas,
je ne le sens pas) le tout déchiffré et monté sur `/home` lors de l’ouverture de
ma session sans étape supplémentaire.

# Avec un disque

Commençons par un seul disque, dont le mot de passe luks sera identique à
votre mot de passe de session. Il n’y a pas de grande difficulté ici, mais cela
pourra vous aider à comprendre la suite.

Donc nous avons une partition vierge, `/dev/sda1`, que nous allons chiffrer :

```
# pacman -S cryptsetup
# cryptsetup luksFormat /dev/sda1
```

Oui je suis passé à archlinux récemment. C’est ici qu’il faut que le mot de passe
doit identique à votre mot de passe système. Bon maintenant nous pouvons
déchiffrer la partition pour y placer un système de fichier btrfs :

Pour que cela fonctionne, il ce peux que vous ayez besoin de charger des modules
supplémentaires :

```
# modprobe dm_mod
```

Nom du module à ajouter dans `/etc/modules-load.d/lucks.conf` pour qu’il soit
chargés automatiquement au démarrage.

```
# cryptsetup luksOpen /dev/sda1 sda1
# mkfs.btrfs /dev/mapper/sda1
# mount /dev/mapper/sda1 /home
```

Maintenant vous pouvez recopier votre ancien dossier `/home`.

Il nous reste à effectuer les deux dernières commandes automatiquement lors de
l’ouverture de notre session. Pour se faire, `pam_mount` va nous être d’une
grande aide avec son système de modules (d’où son nom : *plugggable
authentification modules*) pour s’intercaler dans le système d’authentification
pour y exécuter des commandes.

```
# pacman -S pam_mount
```

Puis modifiez le fichier `/etc/pam.d/system-auth` pour y insérer le module
`pam_mount.so` (trois fois) :

```
#%PAM-1.0

auth      required  pam_unix.so     try_first_pass nullok
auth      optional  pam_mount.so
auth      optional  pam_permit.so
auth      required  pam_env.so

account   required  pam_unix.so
account   optional  pam_permit.so
account   required  pam_time.so

password  optional  pam_mount.so
password  required  pam_unix.so     try_first_pass nullok sha512 shadow
password  optional  pam_permit.so

session   optional  pam_mount.so
session   required  pam_limits.so
session   required  pam_unix.so
session   optional  pam_permit.so
```

Et enfin, dans `/etc/security/pam_mount.conf.xml`, entre les balises
`<pam_mount>` :

```
<volume user="sanpi" fstype="crypt" path="/dev/sda1" mountpoint="/home" />
```

Avant de redémarrer, penser à supprimer la ligne dans `/etc/fstab`.

# Deux disques

C’est ici que les choses se gâtent, en effet nous ne pouvons pas utiliser encore
une fois notre mot de passe pour chiffrer la seconde partition et nous devons
déchiffrer les deux partitions du RAID1 avant d’en monter une seule.

Pour le premier problème, nous allons passer par un conteneur chiffré qui
contraindra les clés pour nos deux partitions. Pour le second, nous passerons
par `pam_exec` pour exécuter un script. C’est parti !

Commençons par le conteneur chiffré :

```
# modprobe loop
# mkdir -p /opt/keys/uncrypt
# pmt-ehd -f /opt/keys/key -u sanpi -s 256
# cryptsetup luksOpen /opt/keys/key keys
# mount /dev/mapper/keys /opt/keys/uncrypt
```

Créons les deux clés, dans le conteneur chiffré :

```
# head -c 64 /dev/random > /opt/keys/uncrypt/sda1.key
# head -c 64 /dev/random > /opt/keys/uncrypt/sdb1.key
```

Et ensuite, mettons en place notre RAID :

```
# cryptsetup luksFormat --key-file="/opt/keys/uncrypt/sdb1.key" /dev/sdb1
# cryptsetup luksOpen --key-file="/opt/keys/uncrypt/sdb1.key" /dev/sdb1 sdb1
# mkfs.btrfs /dev/mapper/sdb1
# btrfs device add /dev/mapper/sdb1 /home
# btrfs filesystem balance start -dconvert=raid1 -mconvert=raid1 /home
```

Vous pouvez prendre une pause pour réfléchir sur le sens de la vie et données à
une association.

N’oublions pas de remplacer le mot de passe de la première partition par le
fichier clé :

```
# crypsetup luksAddKey /dev/sda1 /opt/keys/uncrypt/sda1.key
# cryptsetup luksRemoveKey /dev/sda1
Entrez la phrase secrète à effacer :
```

Bon, il nous reste plus qu’à inclure cela dans `pam`. Plutôt que de monter
directement notre partition, `pam_mount` va déchiffrer notre conteneur de clés :

```
<volume user="sanpi" fstype="crypt" path="/opt/keys/key" mountpoint="/opt/keys/uncrypt" />
```

Puis dans le fichier `/etc/pam.d/system-auth` nous allons ajouter `pam_exec`
après les lignes `pam_mount` ajoutées au paragraphe précédent :

```
auth      optional  pam_exec.so     stdout /usr/local/bin/mount_home
```

> ***note*** idem pour la section `password` et `session`.

Et enfin notre script :

```
#!/bin/bash

mount | grep -q '/home' && exit 0

cryptsetup --key-file=/opt/keys/uncrypt/sdb1.key open /dev/sdb1 _dev_sdb1
cryptsetup --key-file=/opt/keys/uncrypt/sda1.key open /dev/sda1 _dev_sda1
mount /dev/mapper/_dev_sda1 /home
umount.crypt /opt/keys/key
```

Tordu, mais ça marche :)

Maintenant, n’oubliez pas de remplir votre partition chiffrer de n’importe quoi
pour éviter d’avoir une pile de zéro :

```
dd if=/dev/urandom of=~/random
```

Et, éventuellement, réserver le même traitement à votre ancien disque avant de
le
[recycler](https://blog.nicelab.org/donnez-une-nouvelle-jeunesse-a-vos-disques-durs/).

[^1]: Avec btrfs, mais cela n’a que peux d’importance.
