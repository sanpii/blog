Title: Data independenza pour le voyage à Nantes
Date: 2015-06-28 01:10
Tags: open data

Mise à jour : la [version
2016](https://umap.openstreetmap.fr/fr/map/voyage-a-nantes-2016_96887).

Comme chaque été, depuis maintenant 4 ans à lieu le [voyage à
Nantes](https://fr.wikipedia.org/wiki/Le_Voyage_%C3%A0_Nantes). Il s’agit d’un
parcours dans la ville ponctuée d’œuvres.

En allant chercher des info sur le site, je tombe rapidement sur le
[plan](http://www.levoyageanantes.fr/parcours-plan/). Super un tracé GPS avec
des points d’intérêts, le descend, ok un lien pour partager… Et pas de lien pour
télécharger le fichier gpx. Bon je désactive uBlock, je recharge la page. Très
bien encore plus de liens inutiles pour partager mais toujours pas moyen de
récupérer quelque chose d’exploitable une fois que j’aurais quitté mon
fauteuil.

Quand même Nantes, ville labellisée [french
tech](https://fr.wikipedia.org/wiki/French_Tech), siège de
[LiberTIC](https://fr.wikipedia.org/wiki/LiberTIC). Je demande tout de même au
gestionnaire de la communauté sur twitter, si à tout hasard il n’aurait pas ça
dans ses cartons, avec la collaboration de Kheops pour y coller les bons
*buzzwords* :

<blockquote class="twitter-tweet" lang="fr">
    <p lang="fr" dir="ltr">.<a href="https://twitter.com/levoyageanantes">@levoyageanantes</a> tu aurais la trace GPS de la ligne verte ?</p>

    &mdash; sanpi (@sanpi_) <a href="https://twitter.com/sanpi_/status/614775137443938304">27 Juin 2015</a>
</blockquote>
<blockquote class="twitter-tweet" lang="fr">
    <p lang="und" dir="ltr"><a href="https://twitter.com/sanpi_">@sanpi_</a> <a href="https://twitter.com/levoyageanantes">@levoyageanantes</a> <a href="https://twitter.com/hashtag/OpenData?src=hash">#OpenData</a>? :)</p>

    &mdash; KheOps (@kheops2713) <a href="https://twitter.com/kheops2713/status/614775766887329793">27 Juin 2015</a>
</blockquote>

Dans l’attente d’une réponse, je commence à fouiller le code du site en
m’attendant à tomber directement sur le fichier tant convoité. Et c’est à partir
de là que cela devient amusant :)

## Le tracé

La page <http://www.levoyageanantes.fr/parcours-plan/> se contente d’inclure une
iframe vers
<http://www.levoyageanantes.fr/wp-content/themes/levoyageanantes2015/maps/VANMAP_2015.php>
dans laquelle on trouve directement les coordonnées du tracé :

```javascript
// LIGNE VERTE
var ligne_principale_path = [

new google.maps.LatLng(47.215976,-1.542238),
new google.maps.LatLng(47.215779,-1.542538),
new google.maps.LatLng(47.215761,-1.542646),
new google.maps.LatLng(47.215688,-1.543059),
new google.maps.LatLng(47.215874,-1.543509),
new google.maps.LatLng(47.215943,-1.543799),
new google.maps.LatLng(47.215976,-1.544309),
new google.maps.LatLng(47.215910,-1.544850),
new google.maps.LatLng(47.215735,-1.545612),
new google.maps.LatLng(47.215575,-1.545730),
```

Bon j’ouvre la page wikipédia du [format
GPX](https://fr.wikipedia.org/wiki/GPX_%28format_de_fichier%29), rien de bien
compliqué : il s’agit d’un format XML et les itinéraires sont de la forme[^1] :

```xml
<gpx>
    <rte>
        <name> xsd:string </name> [0..1] ?
        <cmt> xsd:string </cmt> [0..1] ?
        <desc> xsd:string </desc> [0..1] ?
        <src> xsd:string </src> [0..1] ?
        <link> linkType </link> [0..*] ?
        <number> xsd:nonNegativeInteger </number> [0..1] ?
        <type> xsd:string </type> [0..1] ?
        <extensions> extensionsType </extensions> [0..1] ?
        <rtept lat="47.644548" lon="-122.326897">
            <name>rtename</name>
        </rtept>
    </rte>
</gpx>
```

Ce qui, dans mon cas se résume à :

```xml
<gpx>
    <rte>
        <rtept lat="47.644548" lon="-122.326897"></rtept>
    </rte>
</gpx>
```

À l’origine, j’ai fait ceci dans (neo)vim avec une simple regex, mais pour plus
de clarté (je ne suis pas sûr que ce soit l’adjectif approprié), voici la
version bash :

```bash
wget -q http://www.levoyageanantes.fr/wp-content/themes/levoyageanantes2015/maps/VANMAP_2015.php -O - \
    | tail -306 \
    | head -177 \
    | sed 's/new google.maps.LatLng(\([^,]*\),\([^)]*\)),\?/<rtept lat="\1" lon="\2"><\/rtept>/g'
```

Et voilà, nous avons déjà notre trace GPS.

## Les points d’intérêts

N’ayant toujours pas de réponse et après un avoir effectué un [don à l’association
nos oignons](https://nos-oignons.net/campagne2015/), je m’attaque aux P.O.I.

Toujours dans cette [même
page](http://www.levoyageanantes.fr/wp-content/themes/levoyageanantes2015/maps/VANMAP_2015.php),
à la suite des coordonnées du tracé, une ligne m’interpelle :

```javascript
downloadUrl("http://www.levoyageanantes.fr/contenu-carte/", function(doc) {
```

J’ouvre la page : page blanche, dommage… Je prends un thé pour me réveiller et
me rend compte que la page n’est pas vide. Il s’agit bien des marqueurs sous
forme de XML. Dommage pas le même format que GPX qui ressemble à ceci :

```xml
<wpt lon="-122.326897" lat="47.644548">
    <name></name>
    <desc></desc>
</wpt>
```

Bon cette fois ci, pour transformer du XML en XML, j’ai peur que les regex
soient contre-productives, donc j’écris trois lignes de PHP :

```php
<?php

$contents = file_get_contents('php://stdin');
$xml = simplexml_load_string($contents);

foreach ($xml as $line) {
    $line['title'] = ucfirst(strtolower($line['title']));
    $line['subtitle'] = ucfirst(strtolower($line['subtitle']));

    echo <<<EOD
    <wpt lon="{$line['lng']}" lat="{$line['lat']}">
        <name>{$line['title']}</name>
        <desc>{$line['subtitle']}
[[{$line['link']}]]
{{{$line['image']}}}</desc>
    </wpt>
EOD;
}
```

Et c’est parti :

```bash
wget -q http://www.levoyageanantes.fr/contenu-carte/ -O - \
    | php poi.php
```

Il ne reste plus qu’à coller ceci à la suite du tracé, corrigé à la main les « É
» et « È » qui n’ont pas été converti en minuscule et voilà toutes les
informations dans un format utilisable par tous et partout.

## Le partage

J’aurais pu m’arrêter là mais partager un fichier GPX, ce n’est pas terrible.
J’ai donc longuement cherché un site utilisant open street map et des logiciels
libres pour y déposer mon fichier. C’est probablement ce qui m’a pris le plus de
temps…

Il y a bien [www.openstreetmap.org](https://www.openstreetmap.org/) mais il faut
des traces (`<trk>`) et non des routes (`<rte>`) avec un horodatage (bref un
vrai trajet fait avec les pieds).

Après quelques recherches infructueuses, je me suis rappelé du [projet wifi de
faimaison](https://www.faimaison.net/wifi) dont j’avais vu passé une carte sur
un service en ligne, dix minutes pour retrouver le site dans mon historique : il
s’agit d’[umap](https://umap.openstreetmap.fr/).

J’ai simplement configuré le gabarit de la popup pour y rajouter la balise
`desc` et voila !

<iframe width="100%" height="500px" frameBorder="0" src="//umap.openstreetmap.fr/fr/map/voyage-a-nantes_45416?scaleControl=false&miniMap=false&scrollWheelZoom=false&zoomControl=true&allowEdit=false&moreControl=true&datalayersControl=true&onLoadPanel=none&captionBar=false"></iframe>
<p><a href="//umap.openstreetmap.fr/fr/map/voyage-a-nantes_45416">Voir en plein écran</a></p>

Vous pouvez télécharger les données via le menu plus, exporter et partager la
carte.

Ah et sinon il existe une [application pour
Android](https://play.google.com/store/apps/details?id=com.clevercloud.lvan). En
voyant son id, je me suis dit que j’avais peut-être fait cela pour rien :

<blockquote class="twitter-tweet" lang="fr">
    <p lang="fr" dir="ltr"><a href="https://twitter.com/kheops2713">@kheops2713</a> et maintenant que j’ai terminé, je me demande si <a href="https://twitter.com/clever_cloud">@clever_cloud</a> n’aurait pas le fichier GPX de <a href="https://twitter.com/levoyageanantes">@levoyageanantes</a> (cc <a href="https://twitter.com/clementd">@clementd</a>)</p>

    &mdash; sanpi (@sanpi_) <a href="https://twitter.com/sanpi_/status/614968066858983424">28 Juin 2015</a>
</blockquote>

## La suite

Deux semaines plus tard, aucune réponse mais une nouvelle carte est publiée
avec un parcours en vélo le long de la Loire, de Nantes à Saint-Nazaire. Du coup
je ne vais pas me priver pour recommencer :

<blockquote class="twitter-tweet" lang="fr">
    <p lang="fr" dir="ltr">Bon <a href="https://twitter.com/levoyageanantes">@levoyageanantes</a>, je ne vais pas perdre mon temps à te poser la question, je t’envois directement le gpx dans 1h <a href="http://www.estuaire.info/fr/le-parcours/">http://www.estuaire.info/fr/le-parcours/</a> <a href="https://twitter.com/hashtag/OpeningData?src=hash">#OpeningData</a>

    &mdash; sanpi (@sanpi_) <a href="https://twitter.com/sanpi_/status/619441335339220992">10 Juillet 2015</a>
</blockquote>

Il m’aura fallu que 30 minutes :

<iframe width="100%" height="500px" frameBorder="0" src="//umap.openstreetmap.fr/fr/map/estuaire-biennale-dart-contemporain-nantes-saint-n_46693?scaleControl=false&miniMap=false&scrollWheelZoom=false&zoomControl=true&allowEdit=false&moreControl=true&datalayersControl=true&onLoadPanel=undefined&captionBar=false"></iframe>
<p><a href="//umap.openstreetmap.fr/fr/map/estuaire-biennale-dart-contemporain-nantes-saint-n_46693">Voir en plein écran</a></p>

Le front de libération des données.

[^1]: D’aprés la [page wikipedia en
 anglais](https://en.wikipedia.org/wiki/GPS_Exchange_Format#Sample_GPX_document)
