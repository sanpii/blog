title: Mémo sur la génération d’un certificat TLS avec let’s encrypt

Ayant participé à la bêta privée de [let’s encrypt](https://letsencrypt.org/),
j’ai pu jouer un peu avec, en particulier pour automatiser la génération de
certificat, puisque quand j’ai commencé, il n’y avait pas d’intégration avec
nginx et maintenant je ne suis pas friand de laisser un programme modifier mes
vhosts.

Commencez par récupérer l’outils :

```
git clone https://github.com/letsencrypt/letsencrypt
cd letsencrypt
./letsencrypt-auto
```

Je vous conseille de lancer l’interface afin de lire les conditions
d’utilisation du service et de vous familiariser avec son fonctionnement
(informations demandées et challenge de validation).

Bon l’interface est sympa, mais la lancer tous les trois mois pour générer des
dizaines de certificats[^1], ce n’est pas envisageable. Passons donc à
l’automatisation.

Créez un fichier `/etc/letsencrypt/config.cli.ini` :

```
text = True
agree-dev-preview = True
rsa-key-size = 4096
agree-tos = True
authenticator = webroot
webroot-path = /tmp/letsencrypt/public_html
```

Le plus important ici, est les deux dernières options qui permettent de gérer
l’authentification avec notre propre serveur http. Let’s encrypt va déposer les
fichiers dans `webroot-path` et tenter de les récupérer via le nom de domaine du
certificat dans le sous-dossier `.well-known`.

Voici donc la configuration pour nginx à placer dans chacun de vos vhost :

```
location /.well-known {
    add_header Content-Type application/jose+json;
    root /tmp/letsencrypt/public_html/;
}
```

Pendant que vous êtes dans la configuration de nginx, profitez en pour générer
une configuration TLS convenable  :
<https://mozilla.github.io/server-side-tls/ssl-config-generator/>.

Pour finir le script à placer en crontab pour mettre à jour l’ensemble de vos
certificats :

[paste:src/files/letsencrypt.sh]

Un peu de bash velu, le plus compliqué étant de retrouver le nom de domaine
racine pour renseigner l’email.

La seule limitation est d’avoir une directive `server_name` par nom de domaine
(ce qui doit ce corriger simplement) et surtout sans expression rationnelle.

Pour aller plus loin, vous pouvez également lire [ce
sujet](https://community.letsencrypt.org/t/howto-a-with-all-100-s-on-ssl-labs-test-using-apache2-4-read-warnings/2436).


[^1]: Les certificats joker ne sont pas à l’ordre du jour :
  <https://github.com/letsencrypt/boulder/issues/21>.
