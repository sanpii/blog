title: Mémo sur la génération d’un certificat TLS avec let’s encrypt

Ayant participé à la bêta privée de [let’s encrypt](https://letsencrypt.org/),
j’ai pu jouer un peu avec, en particulier pour automatiser la génération de
certificat, puisque quand j’ai commencé, il n’y avait pas d’intégration avec
nginx et maintenant je ne suis pas friand de laisser un programme modifier mes
vhosts.

## Installation

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

## Automatisation

Créez un fichier `/etc/letsencrypt/config.cli.ini` :

```ini
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

```nginx
location /.well-known/acme-challenge {
    add_header Content-Type application/jose+json;
    root /tmp/letsencrypt/public_html;
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

Notez, qu’afin de tenir compte [des
limitations](https://community.letsencrypt.org/t/rate-limits-for-lets-encrypt/6769),
seul les certificats de plus de 60 jours sont renouvelés.

Une fois que vous avez votre premier certificat, vous pouvez l’ajouter à votre
vhost :

```nginx
ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
```

Pour aller plus loin, vous pouvez également lire [ce
sujet](https://community.letsencrypt.org/t/howto-a-with-all-100-s-on-ssl-labs-test-using-apache2-4-read-warnings/2436).

## Proxy

Nginx est un excellent proxy cache[^2]. Dans ce cas il faut commencer par
chercher le challenge en local et s’il n’est pas trouvé se rabattre sur le
serveur primaire (dans le cas où l’on génère le certificat sur ce dernier).
Enfin passer également toutes les autres requêtes via `$primary_server_ip`.

```nginx
location /.well-known/acme-challenge {
    add_header Content-Type application/jose+json;
    root /tmp/letsencrypt/public_html;
    try_files $uri @proxy_pass;
}

location / {
    error_page 418 = @proxy_pass;
    return 418;
}

location @proxy_pass {
    proxy_pass $scheme://$primary_server_ip:$server_port;

    proxy_cache STATIC;
    proxy_cache_key $host$request_uri;
    proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_503 http_504;
    proxy_cache_purge PURGE from $primary_server_ip;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    add_header X-Cache-Status $upstream_cache_status;
}
```

## Résultat

[![ssllabs A+](|filename|/images/letsencrypt/ssllabs.png)](https://tls.imirhil.fr/https/sanpi.homecomputing.fr)
[![cryptcheck A+](|filename|/images/letsencrypt/cryptcheck.png)](https://www.ssllabs.com/ssltest/analyze.html?d=sanpi.homecomputing.fr)

[^1]: Les certificats joker ne sont pas à l’ordre du jour :
  <https://github.com/letsencrypt/boulder/issues/21>.
[^2]: Si on omet la stupidité d’avoir réservé la commande PURGE à [la version
  commerciale](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache_purge).
  Cela se contourne avec un bout de bash…
