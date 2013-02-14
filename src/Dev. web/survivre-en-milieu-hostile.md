Title: Survivre en milieu hostile
Date: 2010-12-16 09:54
Tags: Libre, Vim, Windows

Non il ne s’agit pas d’un cours de survie, quoi que, mais un aperçu rapide de
ma configuration pour un poste de travail sous Windows, afin d’être un peu plus
à l’aise pour travailler lorsqu’on est habitué à GNU/Linux.

Les habitués auront remarqués la faible activité de mon blog, en grande partie
parce que j’ai débuté un nouvel emploi couplé à un déménagement. Comme
toujours, qui dit nouveau travail, dit nouveau poste à configurer et jusqu’à
présent j’ai toujours eu le choix entre Windows et Windows (je vous rassure,
ils me payent pour travailler dessus).

Le problème c’est que j’ai l’impression d’être moins efficace que lorsque
j’utilise GNU/Linux, afin d’éviter le troll, il s’agit peut être du manque
d’expérience dans l’utilisation de Windows, peut être… Dans tous les cas, je
dois bien m’adapter (je vais attendre un peu avant d’installer une machine
virtuelle), j’ai donc, au fils de mes maigres années d’expériences, acquis des
réflexes dès que j’arrive sur un nouveau PC que je vais vous livrer
aujourd’hui.

Installez vos logiciels habituels
---------------------------------

Si le passage de Windows à GNU/Linux est difficile c’est en grande partie parce
qu’il faut apprendre à utiliser de nouveaux logiciels, par chance le chemin
inverse est beaucoup plus simple puisqu’une grande partie des logiciels
disponibles sous GNU/Linux est multi-plateforme, il serait dommage de s’en
priver ! Voici donc une liste des logiciels que j’ai installé en remplacement
des classiques pré-installés :

* [OpenOffice.org](http://fr.openoffice.org/) ;
* [Firefox](http://www.mozilla-europe.org/fr/firefox/) ;
* [Evince](http://projects.gnome.org/evince/) ;
* [7zip](http://7zip.fr/) ;
* [Filezilla](http://filezilla-project.org/) ;
* [the gimp](http://www.gimp.org/) ;
* [Tortoise Git](http://code.google.com/p/tortoisegit/) ;
* [Tortoise SVN](http://tortoisesvn.tigris.org/) ;
* [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) ;
* [VirtuaWin](http://virtuawin.sourceforge.net/) ;
* [gvim](http://www.vim.org/) ;
* [MSYS](http://www.mingw.org/wiki/msys) ;
* [console](http://sourceforge.net/projects/console/).

Il en existe bien d’autres, mais je vous rappelle qu’il s’agit de mon poste de
travail…

J’aimerai revenir sur les trois derniers qui nécessite un peut plus de trois
cliques pour être utilisables, mais avant quelques petites astuces concernant
votre bureau.

Retrouver sa maison
-------------------

Comme souvent, mon PC dispose de deux disques, le premier pour le système et le
second, sauvegardé régulièrement, pour mes données. Ce disque serait monté dans
le répertoire */home* sous GNU/Linux, mais cette fonctionnalité - pourtant
proposée par NTFS - n’ayant pas trouvés ses aficionados, je me retrouve avec un
disque *d:*.

Pour que certains logiciels (vim et msys principalement) s’y retrouvent, il
suffit de définir la variables d’environnement *HOME*.

Une barre d’outils utile
------------------------

Sous Windows XP (ça a changé depuis, même si ce n’est toujours pas à mon goût),
le menu démarrer devient vite un joyeux bordel où il est impossible d’y
retrouver rapidement un programme. C’est admissible (en tout cas les
utilisateurs s’en accommodent) dans le cas d’une utilisation normale puisque
les programmes sont lancés via leur association à des fichiers (en clair je
clique sur un fichier .doc pour lancer MS Word), mais c’est moins souvent mon
cas. Il est possible de mettre des raccourcis sur le bureau, mais cela oblige à
minimiser toutes les fenêtres pour lancer un nouveau programme, et j’aime bien
avoir un bureau vide (qu’il soit réel ou virtuel).

La solution que j’ai trouvé consiste à créer un répertoire contenant l’ensemble
des raccourcis puis de créer une nouvelle barre d’outils : clique droit sur
celle existante, barre d’outils &gt; Nouvelle barre d’outils puis sélectionner
votre répertoire. Vous obtenez alors un menu portant le nom de votre répertoire
et en déverrouillant la barre d’outils (toujours à l’aide du menu contextuel)
vous pouvez le déplacer sur l’un des côté de l’écran pour créer une nouvelle
barre d’outils.

Un éditeur de texte avec des bulles qui montent
-----------------------------------------------

Vim peut demander plusieurs années pour être configuré selon vos désirs, mais
l’avantage c’est qu’une fois votre choix fait, il suffit de copier votre
fichier *.vimrc* sur votre nouvelle machine et vous retrouvez votre
configuration ! Si vous n’en avez pas encore, il en existe énormément sur le
net, [dont le
mien](http://projects.homecomputing.fr/p/my-dotfiles/source/tree/master/vimrc),
testez et faites votre choix.

Le problème, les habitués devraient rapidement s’en rendre compte, c’est qu’un
certain nombre de raccourcis ont été définis afin de faciliter la vie aux
habitués des éditeurs plus classiques (par exemple : &lt;c-a&gt; pour
sélectionner tout le texte, &lt;c-c&gt; pour copier, &lt;c-v&gt; pour coller,
…). Plus les supprimer, il suffit de commenter la ligne suivante dans le
fichier *C:\Program Files\Vim\_vimrc* :

    source $VIMRUNTIME/mswin.vim

C’est également dans ce fichier que vous pouvez modifier le chemin de votre
*.vimrc* (la ligne juste au dessus).

Retrouver l’usage du clavier
----------------------------

Il existe bien une console sous Windows, pour travailler en ligne de commande,
mais je ne suis pas sûr de gagner en productivité en l’utilisant…

Pour retrouver vos outils habituels (ls, grep, …) vous pouvez installer MSYS
(qui fait partie du projet MinGW) qui vous propose les binaires compilés pour
Windows. Vous trouverez les instructions pour l’installation sur le [wiki de
mingw](http://www.mingw.org/wiki/msys) et ensuite vous pouvez fouiller dans le
[dépot](http://sourceforge.net/projects/mingw/files/MSYS/) (sic) pour y
télécharger et installer de nouveaux paquets (re-sic).

Vous disposez déjà de bons outils, malheureusement l’interface (la console)
proposée n’est pas extraordinaire. Sans vouloir surpasser ce qui existe sous
Linux, le minimum syndical serait de disposer d’onglets, c’est ce que vous
apporte [console](http://sourceforge.net/projects/console/).

Conclusion
----------

Maintenant vous devriez vous sentir plus à l’aise pour travailler. Jonglant
entre Firefox et Vim je n’ai pas l’impression d’être sous Windows, à
l’exception de quelques ralentissement inexpliqués. Ce qui me manque encore
cruellement est un explorateur de fichiers rapide, avec des onglets et qui
s’intègre parfaitement au système.

Si vous avez d’autres astuces, n’hésitez pas à les partager ;)
