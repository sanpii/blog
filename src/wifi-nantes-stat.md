Title: Big data, big n’importe quoi
Tags: wifi-nantes
Date: 2018-02-13 20:01:28
image: /images/header/mathematiques.jpg

Dans le cadre de l’expérimentation sur le wifi public de la ville de Nantes,
plusieurs membres de FAIMaison ont assistés à la première réunion prévue pour
lancer l’étude.

Au vu du matériel utilisé, nous avions (et pour ma part, j’ai toujours) peur de
l’utilisation qui pourrait être faite pour pister les citoyen·ne·s, mais je ne
vais pas m’attarder sur la partie technique ici, il y aura probablement un autre
billet plus tard. Non ici je vais simplement vous démontrer qu’avoir plein de
données, le big data, ça peut vite être risible quand on n’a pas un minimum de
connaissance en mathématiques.

Rassurez-vous, n’étant pas un grand mathématicien, cela restera relativement
simple.

[Le diaporama](|filename|/files/Premiers-résultats-statistiques-MC.pdf) contient 8 pages, les
choses amusantes commencent dès la troisième :

![](|filename|/images/wifi-nantes-stats/durée-connexion.png)

Bon on commence doucement avec une moyenne. Seule. Une moyenne ne sert à rien
sans écart type[^1]. C’est bête, mais c’est niveau collège. Je précise tout de
même que cette étude a été payée avec nos impôts à [TMO
Regions](http://www.tmoregions.fr/), qui se présente comme un « Institut
d’études, de sondages, de conseils et d’expertise ».

Toujours sur cette page, j’aimerais bien que quelqu’un·e m’explique ce qui est
censé être mis en évidence avec le camembert en dessous. Les tranches de temps
ne sont pas identiques. Pourquoi avoir coupé la tranche 5-10 minutes en deux
alors d’avoir une la version complète est bien plus parlante :

![](|filename|/images/wifi-nantes-stats/cammebert.png)

Bon mais comparé à la page suivante, c’est presque du pinaillage…

![](|filename|/images/wifi-nantes-stats/par-jours.png)

Celle-ci, je dois l’avouer, je ne l’ai pas vu sur le coup mais c’est tout
simplement génial de bêtise : 5/7ᵉ de la semaine représente 74 % du nombre de
connexions. 5/7, c’est exactement 71 % du temps qui représente donc 74 % du
nombre de connexions, magique, non ?

![](|filename|/images/wifi-nantes-stats/par-heure.png)

Bon là, le graphique à droite nous apprend qu’une majorité de gens dorment la
nuit, mais ce qui est vraiment drôle c’est celui sur la gauche. Regardez bien
les tranches horaires… Et oui encore des tranches inégales !

![](|filename|/images/wifi-nantes-stats/utilisateurs.png)

Bon, page suivante cette page je vous la laisse en exercice, on y retrouve deux
biais déjà évoqués.

![](|filename|/images/wifi-nantes-stats/constructeur.png)

À celle-ci est un peu plus intéressante, car en plus de nous apprendre que la
métropole collecte les adresses mac des téléphones connectés, ont voit que cela
ne leur sert à rien pour faire des analyses pertinentes… Une information
pertinente (mais pas forcement plus utile) est de regrouper les terminaux par
systèmes (soit 51 % iphone et 49 % android).

Ah et si vous n’êtes pas convaincu du manque de pertinence de la collecte des
adresses mac, cette slide du FOSDEM de cette année devrait vous éclaircir sur le
sujet :

![](|filename|/images/wifi-nantes-stats/fosdem.png)

Histoire de savoir combien cette blague nous a coûté, j’ai fait une demande
d’accès aux documents administratifs auprès de Nantes métropole resté sans
réponse, il reste encore 2 mois avant de saisir la CADA.

[^1]: C’est comme donner le centre de gravité d’un parallélépipède pour vous
  donner une idée de sa forme, avoir une idée de la distance des arêtes avec ce
  centre est un minimum.
