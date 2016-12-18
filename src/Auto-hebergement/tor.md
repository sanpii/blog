title: Créer un service tor pour vos sites
image: /images/header/tor.png
date: 2016-01-05 14:10:34

Je vous ai dit à quel point j’étais content d’avoir joué à chiffrer mes disques
durs avant d’en ressentir le besoin[^1] ? Du coup, en assistant au talk
[Tor onion services more useful than you
think](https://media.ccc.de/v/32c3-7322-tor_onion_services_more_useful_than_you_think)
lors du 32c3, je me suis dit qu’il était temps de m’intéresser à ces derniers.

Pour commencer il faut installer le paquet `tor`, depuis le dépôt du projet,
afin d’être sûr d’avoir la dernière version. Je vous laisse suivre la
[documentation officielle](https://www.torproject.org/docs/debian.html.en) pour
cette partie (ça évitera que vous suiviez des instructions obsolètes).

Et on installe tor :

```
# apt update
# apt install tor deb.torproject.org-keyring
```

Pour chaque service que vous souhaitez exposer via tor, si suffit d’ajouter ces
deux lignes dans le fichier `/etc/tor/torrc` :

```
HiddenServiceDir /var/lib/tor/search.homecomputing.fr
HiddenServicePort 80 127.0.0.1:80
```

Une fois le service tor rechargé, vous trouverez deux fichiers dans le
répertoire :

```
/var/lib/tor/search.homecomputing.fr
├── hostname
└── private_key
```

Il vous reste plus qu’à ajouter le contenu du fichier `hostname` (qui, comme son
nom le laisse penser, contient votre domaine .onion) à la configuration de votre
serveur web et le redémarrer :

```
server_name ayobcipurplcm6ba.onion;
```

Et voilà le résultat : <http://ayobcipurplcm6ba.onion>. Tous simplement. Si vous
souhaitez ajouter un autre site, il suffit de répéter ses deux étapes.

Pour obtenir un nom de domaine un peu moins aléatoire, vous pouvez utiliser
[shallot](https://github.com/katmagic/Shallot) :

```
$ shallot '^sanpi'
------------------------------------------------------------------
Found matching domain after 30429473 tries: sanpii6qqjdzws77.onion
------------------------------------------------------------------
-----BEGIN RSA PRIVATE KEY-----
…
-----END RSA PRIVATE KEY-----
```

Comme l’indique le readme du projet, il va falloir être raisonnable sur le
nombre de caractères :

```
characters | time to generate (approx.)
---------------------------------------
         1 |         less than 1 second
         2 |         less than 1 second
         3 |         less than 1 second
         4 |                  2 seconds
         5 |                   1 minute
         6 |                 30 minutes
         7 |                      1 day
         8 |                    25 days
         9 |                  2.5 years
        10 |                   40 years
        11 |                  640 years
        12 |                10 millenia
        13 |               160 millenia
        14 |          2.6 million years
```

Ensuite, copier simplement le nom de domaine et la clés privée dans les fichiers
vu précédemment et voilà : <http://sanpii6qqjdzws77.onion>.

Vous pouvez bien évidemment créer des sous domaines. Rien de spécial à faire,
simplement renseigner le `server_name` : <http://sanpi.hcptwrrqn6iuhmsv.onion>.

Le plus compliqué dans l’histoire n’est pas tor mais vos services : il faut vous
assurer que le maximum de ressources sont servies via tor pour éviter les fuites
de données de vos visiteurs.

[^1]: Durant l’état d’urgence, lors de perquisition, les données présentes sur
  les lieux peuvent copiées :
  <http://www.legifrance.gouv.fr/eli/loi/2015/11/20/2015-1501/jo/article_4>
