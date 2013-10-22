# Exemple de structure de la table teleinfo à créer chez son FAI:
CREATE TABLE IF NOT EXISTS `teleinfo` (
  `timestamp` bigint(10) NOT NULL default '0',
  `rec_date` date NOT NULL default '0000-00-00',
  `rec_time` time NOT NULL default '00:00:00',
  `adco` varchar(12) character set latin1 collate latin1_general_ci NOT NULL,
  `optarif` varchar(4) character set latin1 collate latin1_general_ci NOT NULL,
  `isousc` tinyint(2) NOT NULL default '0',
  `hchp` bigint(9) NOT NULL default '0',
  `hchc` bigint(9) NOT NULL default '0',
  `ptec` varchar(2) character set latin1 collate latin1_general_ci NOT NULL,
  `inst1` tinyint(3) NOT NULL default '0',
  `inst2` tinyint(3) NOT NULL default '0',
  `inst3` tinyint(3) NOT NULL default '0',
  `imax1` tinyint(3) NOT NULL default '0',
  `imax2` tinyint(3) NOT NULL default '0',
  `imax3` tinyint(3) NOT NULL default '0',
  `pmax` int(5) NOT NULL default '0',
  `papp` int(5) NOT NULL default '0',
  `hhphc` varchar(1) character set latin1 collate latin1_general_ci NOT NULL,
  `motdetat` varchar(6) character set latin1 collate latin1_general_ci NOT NULL,
  `ppot` varchar(2) character set latin1 collate latin1_general_ci NOT NULL,
  `adir1` tinyint(3) NOT NULL default '0',
  `adir2` tinyint(3) NOT NULL default '0',
  `adir3` tinyint(3) NOT NULL default '0',
  UNIQUE KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
