Title: Installation d’un serveur FTP
Date: 2010-07-06 14:35
Tags: Debian, Libre, ftp

Le protocole FTP permet, comme son nom l’indique, le transfert de fichiers d’un
client vers un serveur (dans les deux sens).

Ce protocole est généralement le seul disponible pour les offres mutualisées des
hébergeurs, mais pour un usage personnel, de par mon expérience, je m’en sert
très peut : il est plus rapide de faire un wget via SSH ou encore d’utiliser vi
pour éditer les fichiers. Par contre si vous souhaitez partager votre serveur
c’est une bonne idée de proposer ce service, et au vu de la simplicité
d’installation, il serais dommage de s’en priver.

Il y a encore quelques jours, je vous aurais détaillé l’installation et la
configuration du serveur [proftpd](http://www.proftpd.org/) mais entre temps
j’ai survolé un article qui évoquait l’existence d’un protocole FTP par dessus
SSH : [SFTP](http://fr.wikipedia.org/wiki/SSH_file_transfer_protocol).

Ayant installé SSH dans un [précédent
billet](|filename|acces-a-distance.md), vous pouvez
utiliser SFTP (voila pour la partie installation...).

Concernant la partie configuration, l’authentification est basée sur le système
de clés SSH, donc encore une fois pas grand chose à ajouter. Pour tester, vous
pouvez utiliser le programme *sftp* en ligne de commande (similaire à la
commande *ftp*) ou un client graphiqe comme
[filezilla](http://filezilla-project.org/)).

Un petit problème cependant : la configuration par défaut permet à l’utilisateur
de se balader sur l’ensemble du disque, à condition qu’il ait les permissions,
mais il plus courant de bloquer l’utilisateur dans son répertoire personnel,
c’est à dire dans un environnement
[chrooter](http://fr.wikipedia.org/wiki/Chroot).

C’est là que les choses se corsent légèrement, si vous êtes le seul utilisateur
de votre serveur je vous conseille de vous arrêter là[^1].

Pour les autres, ou les curieux, depuis la version 4.9 de OpenSSH, il existe
l’option *ChrootDirectory* qui permet de définir un répertoire de base. Il faut
pour cela utiliser le serveur ftp interne à ssh. Éditez le fichier
*/etc/ssh/sshd\_config* et y ajouter :

    Subsystem sftp internal-sftp
    ChrootDirectory /var/www/users/%u
    ForceCommand internal-sftp

Pour que cela fonctionne, il faut que le propriétaire du répertoire de base soit
*root*, c’est pour cette raison que j’ai choisi un répertoire dans
*/var/www/users/* plutôt que le répertoire par défaut de l’utilisateur[^2]. Par
conséquent, l’utilisateur ne pourra pas écrire dans le répertoire de base (c’est
à dire créer de nouveaux fichiers), rien de dramatique, il suffit de lui créer
les répertoires de bases (cgi-bin et public\_html par exemple).

Au final, une installation extrêmement simple, une configuration tout aussi
simple pour un serveur personnel et une sécurité accrue. Par contre, si l’on
souhaite profiter du *chroot*, comme pour un FTP classique, les choses se
compliquent. Pour l’utilisation que j’ai de mon serveur, le choix est vite fait :
encore quelques mots de passe en moins à retenir !

[^1]: Suite à un éclair de génie de dernière minute, j’ai trouvé une autre
solution : passer les droits du répertoire /home à 751 ce qui empêche aux
autres utilisers (hors *root* et les membres du groupe homonyme) de lire le
contenu du répertoire. J’ai tester en FTP et SSH, ça fonctionne, mais je ne
suis pas sûr de cerner l’ensemble des conséquences, à confirmer donc…
[^2]: Attention, il semblerai que l’option *ChrootDirectory* affecte uniquement
le protocole FTP, et pas SSH, l’utilisateur aura donc accès à son répertoire
/home en SSH et /var/www/users en FTP, l’accès SSH n’est plus utile.
