Title: Récupérer les flags IMAP en PHP
Date: 2011-01-19 12:02
Tags: PHP, Imap

Comme promis hier sur [identi.ca](https://identi.ca/notice/62497778) voici le
billet qui va vous expliquer comment récupérer les étiquettes IMAP en PHP.

D'abord qu'est ce que ces étiquettes et pourquoi j'étais si content d'arriver à
les récupérer ? Il s'agit simplement de *flags* prédéfinis ou non que l'on peux
ajouter à un message (pour les curieux, tout ceci est défini dans la [RFC
5232](http://tools.ietf.org/html/rfc5232)). Les utilisateurs de gmail les
connaissent bien, c'est d'ailleurs ce dernier qui m'a conduit jusque là : j'ai
trouvé aucun webmail en PHP proposant les mêmes fonctionnalités que gmail, j'ai
donc décidé de créer mon clone de gmail écrit en PHP et libre.

C'est en arrivant à la récupération de ces fameuses étiquettes que j'ai compris
pourquoi il y avait si peu de client : il n'existe pas de fonction pour le
faire. Il y a bien un bug rouvert récemment :
[#53043](http://bugs.php.net/bug.php?id=53043) (l'original date tout de même de
2003) mais cela semble n'intéresser personne…

Pour ceux qui ne sont pas familier avec les serveurs de mails, il faut savoir
que c'est extrêmement simple de dialoguer directement avec : tout peut se faire
avec *telnet* en tapant les commandes adéquates, comme je le fait dans un
[billet précédent pour l'installation d'un serveur
IMAP](|filename|/Auto-hebergement/consultez-vos-emails-a-distance.md).

Voici à quoi ressemble une discussion pour récupérer uniquement les étiquettes
d'un mails :

    $ telnet 192.168.51.5 143
    Trying 192.168.51.5...
    Connected to 192.168.51.5.
    Escape character is '^]'.
    * OK Dovecot ready.
    > x LOGIN sanpi secret
    x OK Logged in.
    > x SELECT INBOX
    * FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
    * OK [PERMANENTFLAGS (\Answered \Flagged \Deleted \Seen \Draft \*)] Flags permitted.
    * 1 EXISTS
    * 0 RECENT
    * OK [UNSEEN 1] First unseen.
    * OK [UIDVALIDITY 1286421452] UIDs valid
    * OK [UIDNEXT 2] Predicted next UID
    x OK [READ-WRITE] Select completed.
    > x FETCH 1 (FLAGS)
    * 1 FETCH (FLAGS (\Seen))
    x OK Fetch completed.
    > x LOGOUT
    * BYE Logging out
    x OK Logout completed.
    Connection closed by foreign host.

J'ai ajouter le signes **>** devant les lignes tapées. Il ne nous reste plus qu'à faire la même chose en PHP à l'aide d'une socket :

    <?php

    class ImapSocket
    {
        private $_socket;

        private function _gets ()
        {
            $result = array ();
            while (substr ($str = fgets ($this->_socket), 0, 1) == '*')
            {
                $result[] = substr ($str, 0, -2);
            }
            $result[] = substr ($str, 0, -2);
            return $result;
        }

        private function _send ($cmd, $uid = '.')
        {
            $query = "$uid $cmd\r\n";
            $count = fwrite ($this->_socket, $query);
            if ($count == strlen ($query))
            {
                return $this->_gets ();
            }
            else
            {
                throw new Exception ("Une erreur est survenue lors de l'exécution de la commande '$cmd'");
            }
        }

        private function _connect ($server, $port, $tls)
        {
            if ($tls)
            {
                $server = 'tls://'. $server;
            }
            $fd = fsockopen ($server, $port, $errno);
            if (!$errno)
            {
                return $fd;
            }
            else
            {
                throw new Exception ('Impossible d\'ouvrir la connexion vers le serveur IMAP');
            }
        }

        private function _login ($login, $password)
        {
            $result = $this->_send ("LOGIN $login $password");
            $result = array_pop ($result);
            if ($result != ". OK Logged in.")
            {
                throw new Exception ('Login impossible');
            }
        }

        public function __construct ($options, $mailbox = '')
        {
            $this->_socket = $this->_connect ($options['server'], $options['port'], true);
            $this->_login ($options['login'], $options['password']);
            if (!is_null ($mailbox))
            {
                $this->select_mailbox ($mailbox);
            }
        }

        public function __destruct ()
        {
            fclose ($this->_socket);
        }

        public function select_mailbox ($mailbox)
        {
            $result = $this->_send ("SELECT $mailbox");
            $result = array_pop ($result);
            if ($result != ". OK [READ-WRITE] Select completed.")
            {
                throw new Exception ('Impossible de sélectionner la mailbox');
            }
        }

        public function get_flags ($uid)
        {
            $result = $this->_send ("FETCH $uid (FLAGS)");
            preg_match_all ("#\\* \\d+ FETCH \\(FLAGS \\((.*)\\)\\)#", $result[0], &$matches);
            if (isset ($matches[1][0]))
            {
                return explode (' ', $matches[1][0]);
            }
            else
            {
                return array ();
            }
        }
    }

Et il suffit de faire un :

    <?php

    $imap = new ImapSocket (array ('server' => 'localhost',
      'port' => 143,
      'login' => 'sanpi',
      'password' => 'secret'), 'INBOX');
    var_dump ($imap->get_flags (0));

Il faut tout de même noter que cette classe représente l'état actuel du projet,
à savoir expérimental, par exemple :

* la connexion via tls ou ssl n'est pas configurable ;
* la gestion des erreurs est très simple (j'ai déjà utilisé *imap_open* au paravent) ;
* ça marche, mais la fonction _gets est critique : on arrive rapidement à une boucle sans fin si on ne sait pas ce que l'on fait.

En résumé, malgré son nom cette classe est prévue uniquement pour cette usage,
il existe des modules si vous souhaitez une classe plus poussée (ou les
fonctions *imap_**).
