Title: Valider les URL dans un formulaire avec Zend Framework
Date: 2010-08-02 21:25
Tags: PHP, Zend Framework

Oui, je comprends que ce genre de billet peut surprendre bien qu’en tant
qu’auto-hébergeur il peux être nécessaire de créer sa propre applications web,
je dévie un peu du cadre initial de ce blog pour parler un peu de PHP.

Tout simplement parce que c’est l’activité qui a occupé le plus de temps dans ma
vie professionnelle jusqu’à maintenant et je pense la moitié de mes
développements personnels.

Bref, pour débuter voici une petite astuce pour valider les URL dans un
formulaire créé avec Zend Framework.

Lorsque vous ajoutez un élément à un formulaire, il possible d’y ajouter un
validateur afin que la valeur saisie soit automatiquement vérifiée. Il existe un
certain nombre de validateur inclus dans Zend :
[Zend_Validate](http://framework.zend.com/apidoc/core/classtrees\_Zend\_Validate.html)
mais aucun pour vérifier si une URL est valide. Rien d’insurmontable, nous
allons créer le notre en se basant sur
[Zend_Uri](http://framework.zend.com/apidoc/core/Zend_Uri/Zend_Uri.html) :

    :::php
    <?php

    /**
     * @see Zend_Validate_Abstract
     */
    require_once 'Zend/Validate/Abstract.php';

    class Gege2061_Validate_Url extends Zend_Validate_Abstract
    {
      const INVALID     = 'urlInvalid';
      const INVALID_URL = 'urlInvalidFormat';

      /**
       * @var array
       */
      protected $_messageTemplates = array (
        self::INVALID     => "Invalid type given, value should be a string",
        self::INVALID_URL => "'%value%' is not a valid URL.",
      );

      /**
       * Defined by Zend_Validate_Interface
       *
       * Returns true if and only if $value is a valid url
       *
       * @param string $value
       * @return boolean
       */
      public function isValid ($value)
      {
        if (!is_string ($value))
        {
          $this->_error (self::INVALID);
          return false;
        }

        $this->_setValue ($value);

        if (!Zend_Uri::check ($value))
        {
          $this->_error (self::INVALID_URL);
          return false;
        }
        return true;
      }
    }

Il nous reste plus qu’à le mettre en pratique :

    :::php
    <?php

    class Form_Url extends Zend_Form
    {
      public function init()
      {
        $this->addElement ('text', 'url', array (
          'label' => 'An url',
          'required' => true,
          'filters' => array ('StringTrim'),
          'validators' => array (
            new Gege2061_Validate_Url,
          )
        ));
      }
    }

;)
