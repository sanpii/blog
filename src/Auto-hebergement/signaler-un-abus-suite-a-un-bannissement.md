Title: Signalé un abus suite à un bannissement
Date: 2010-08-12 07:39
Tags: Debian, Libre, fail2ban

Si comme moi vous vous amusez à lire les *whois* que vous envoie *fail2ban*,
vous avez peut être remarqué la présence d’une adresse pour rapporter un abus ?
Il est temps de s’en servir !

Afin que les personnes qui s’occupe de ce serveur soit au courant des activités
qui s’y pratique : on ne peut pas exclure un virus qui transforme le serveur en
*bootnet*, je suis tombé par hasard sur un script qui envoi un mail,
malheureusement écrit en Ruby. En quatre heure de temps, j’ai réécrit le script
en bash : [report-ban-isp](http://git.homecomputing.fr/?p=report-ban-isp.git),
vous trouverai en bas de la page la configuration pour fail2ban sous Debian.

Voici le résustat :

> From: sanpi@homecomputing.fr
> Subject: Security Alert - Your Server May Have Been Hacked!
> Date: Thu, 12 Aug 2010 05:32:07 +0200 (CEST)
>
> To whom it may concern.
>
> We have detected a hack attempt originating from your network from ip: XXX.XXX.XXX.XXX
>
> This suggests that the above server has been compromised and is a participant in a botnet.
>
> This means that this server has been hacked and now, in turn, is attempting to hack other servers on the Internet.
>
> This IP address has now been blacklisted to protect our service from further brute force attacks.
>
> An excerpt from our logfiles. All times shown are in GMT+0200:
>
> Aug 11 21:22:57 moisi-server sshd[29006]: Did not receive identification string from XXX.XXX.XXX.XXX
> …
> Aug 12 05:14:08 moisi-server sshd[620]: Did not receive identification string from XXX.XXX.XXX.XXX
>
> Regards.

Pour information, M. XXX.XXX.XXX.XXX en plus d’être averti (plus
particulièrement Orange Romania Network dont le mail figure dans le *whois*
associé à l’IP) d’avoir un serveur très dérangeant a gagné un ban à vie : se
faire bannir trois fois en SSH sur un port supérieur à 2000 ça mérite bien ça.
