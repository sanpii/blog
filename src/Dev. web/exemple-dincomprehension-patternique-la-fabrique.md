Title: Exemple d’incompréhension patternique, la fabrique
Date: 2011-06-14 17:04
Tags: PHP, Design pattern

Ceux qui me suivent sur identi.ca ou twitter on peut être remarqué que [je bosse
sur Mangeto](http://statusnet.homecomputing.fr/notice/18800), enfin bosser… je
me prends la tête avec application PHP qui donne l’impression d’avoir une
conception ultra poussée afin de rendre le développement le plus souple
possible.

Tellement conceptualisée à l’aide de concepts fumeux
qu’une simple surcharge de classe demande une demie journée de travail… Si
seulement les design patterns les plus simples étaient maîtrisés. Voici un
exemple de fabrique :

    <?php

    class Mage_Core_Model_Message
    {
        const ERROR     = 'error';
        const WARNING   = 'warning';
        const NOTICE    = 'notice';
        const SUCCESS   = 'success';

        protected function _factory($code, $type, $class='', $method='')
        {
            switch (strtolower($type)) {
                case self::ERROR :
                    $message = new Mage_Core_Model_Message_Error($code);
                    break;
                case self::WARNING :
                    $message = new Mage_Core_Model_Message_Warning($code);
                    break;
                case self::SUCCESS :
                    $message = new Mage_Core_Model_Message_Success($code);
                    break;
                default:
                    $message = new Mage_Core_Model_Message_Notice($code);
                    break;
            }
            $message->setClass($class);
            $message->setMethod($method);

            return $message;
        }

        public function error($code, $class='', $method='')
        {
            return $this->_factory($code, self::ERROR, $class, $method);
        }

        public function warning($code, $class='', $method='')
        {
            return $this->_factory($code, self::WARNING, $class, $method);
        }

        public function notice($code, $class='', $method='')
        {
            return $this->_factory($code, self::NOTICE, $class, $method);
        }

        public function success($code, $class='', $method='')
        {
            return $this->_factory($code, self::SUCCESS, $class, $method);
        }
    }

Le code respecte probablement la [définition du design
pattern](http://www.croes.org/gerald/blog/la-fabrique-factory-en-php/24/) mais à
quoi bon ? Les développeurs n’ont pas réfléchi deux minutes pour savoir si cela
aller leurs simplifier la vie. S’ils souhaitent ajouter un nouveau type de
message, ils sont obligés de modifier ce code (et probablement quelques autres
classes), sans parler que je ne peux pas ajouter un nouveau type de message
facilement.

Voici donc ma contribution :

    <?php

    class Mage_Core_Model_Message

    {
        public function __call ($name , $arguments)
        {
            $class = 'Mage_Core_Model_Message_'. ucfirst($name);

            $message = new $class($arguments[0]);
            if(isset($arguments[1])) {
                $message->setClass($arguments[1]);
            }
            if(isset($arguments[2])) {
                $message->setClass($arguments[2]);
            }
            return $message;
        }
    }

C’est quand même plus simple, non ? Couplé à un auto-chargement intelligent des
classes on obtient quelque chose de souple, et pas uniquement compliqué à
comprendre pour le plaisir d’utiliser un design pattern hype 2.0.

Bon aller, fini de troller, je retourner chercher pourquoi les satanés messages
ne veulent pas s’afficher…
