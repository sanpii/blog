Title: Ajouter une méthode à une classe sans utiliser l'héritage en PHP
Date: 2011-01-17 22:07
Tags: PHP

Drôle de titre alors que j’aurais pu nommer ce billet :

> Design pattern décorateur avec PHP

Mais je n’aime pas spécialement parler de *design pattern*, même si j’aime bien
le principe, cela implique un ensemble de choses qui a tendance à leur faire
perdre leurs intérêts. Par exemple, on pourrait discuter pendant des heures du
principe du *design pattern* décorateur, un peu comme c’est le cas pour le
[singleton](http://zenprog.com/index.php?cle=Critique-du-design-pattern-singleton).

Pour paraphraser
[Gerald](http://www.croes.org/gerald/blog/nutilisez-pas-les-design-patterns-en-php/109/) :
> N’utilisez jamais les modèles de conception, mais connaissez-les,
maîtrisez-les !

Aujourd’hui, nous n’allons donc pas en parler…

Le but de ce billet est d’évoquer une manière d’ajouter une méthode à une classe
sans utiliser l’héritage. Avant de vous expliquer de ma solution, évoquons le
problème à l’origine de cette solution.

Je suis en train d’explorer la conception d’un webmail en PHP dans lequel
j’utilise une classe *Imap* comme surcouche aux fonctions de l’extension imap de
PHP. L’une des méthodes de cette classe me renvoie les informations de l’entête
d’un message à partir de son identitifiant :

    <?php

    class Imap
    {
        private function get_header($uid)
        {
            $header = imap_header($this->stream, $uid);
            return $header;
        }
    }

*$header* est un objet de type *StdClass* avec un certain nombre de champs
détaillés dans [la
documentation](http://fr2.php.net/manual/en/function.imap-headerinfo.php).
Premier problème il n’y a pas de champs pour savoir si un message a été lu ou
pas.

La première étape va donc être de l’ajouter. Je pense que vous avez déjà tous
fait cela :

    <?php

    class Imap
    {
        private function get_header($uid)
        {
            $header = imap_header($this->stream, $uid);
            $header->seen = ($header->Unseen == 'U' || $header->Recent == 'N');
            return $header;
        }
    }

Maintenant, j’aimerai bien pourvoir disposer du contenu du message.
Malheureusement les requêtes au serveur IMAP sont couteuse en temps, il ne peux
donc pas faire :

    <?php

    $header->body = imap_body($this->stream, $uid);

Puisque la fonction *Imap::get\_header* est appelée lors du listage des
messages d’un dossier. Il serait intéressant de récupérer le contenu à la
demande avec, par exemple une fonction *get_body*, mais cela nécessite de créer
une nouvelle classe et d’y copier l’ensemble des propriétés de l’objet. Pas
forcement long à écrire mais, à mon avis, inutile pour l’utilisation que nous en
avons.

Nous allons donc reprendre le concept précédent, mais au lieu de stocker une
variable, nous allons y mettre un fonction anonyme :

    <?php

    class Imap
    {
        private function get_header($uid)
        {
            $header = imap_header($this->stream, $uid);
            $header->seen = ($header->Unseen == 'U' || $header->Recent == 'N');

            $self = $this;
            $header->get_body = function() use($self, $header) {
                return $self->get_body ($header->uid);
            };
            return $header;
        }

        public function get_body($uid)
        {
            return imap_body($this->stream, $uid);
        }
    }

Nous arrivons sur un premier soucis, la variable *$this* n’est pas utilisable
dans une fermeture (bug [#49543](http://bugs.php.net/bug.php?id=49543), corrigé
dans la version de développement de PHP), nous devons la dupliquer, mais nous
sommes alors dans un contexte public. Le second problème, plus gênant, est
l’impossibilité d’appeler cette fonction directement. Logiquement nous aurions
aimé écrire :

    <div class="body"><?php print $header->get_body(); ?></div>

Dommage… En attendant que le bug
[#51326](http://bugs.php.net/bug.php?id=51326) soit corrigé (dans la prochaine
version majeur de PHP, à première vue), nous pouvons, au choix, écrire :

    <?php $header_get_body = $header->get_body; ?>
    <div class="body"><?php print $header_get_body(); ?></div>

ou

    <div class="body"><?php print call_user_func($header->get_body); ?></div>
