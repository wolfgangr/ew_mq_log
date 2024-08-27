-- Adminer 4.8.1 MySQL 10.11.6-MariaDB-0+deb12u1 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `aux_th`;
CREATE TABLE `aux_th` (
  `idx` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `station` int(2) NOT NULL,
  `sensor` int(2) NOT NULL,
  `temp` decimal(5,2) DEFAULT NULL,
  `humidity` decimal(4,1) DEFAULT NULL,
  `batt` varchar(5) DEFAULT 'NULL',
  PRIMARY KEY (`idx`,`station`,`sensor`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;


DROP VIEW IF EXISTS `last_aux_th`;
CREATE TABLE `last_aux_th` (`idx` datetime, `station` int(2), `sensor` int(2), `temp` decimal(5,2), `humidity` decimal(4,1), `batt` varchar(5));


DROP VIEW IF EXISTS `recent_aux_th`;
CREATE TABLE `recent_aux_th` (`idx` datetime, `station` int(2), `sensor` int(2), `temp` decimal(5,2), `humidity` decimal(4,1), `batt` varchar(5));


DROP TABLE IF EXISTS `last_aux_th`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `last_aux_th` AS select `recent_aux_th`.`idx` AS `idx`,`recent_aux_th`.`station` AS `station`,`recent_aux_th`.`sensor` AS `sensor`,`recent_aux_th`.`temp` AS `temp`,`recent_aux_th`.`humidity` AS `humidity`,`recent_aux_th`.`batt` AS `batt` from `recent_aux_th` group by `recent_aux_th`.`sensor`;

DROP TABLE IF EXISTS `recent_aux_th`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `recent_aux_th` AS select `aux_th`.`idx` AS `idx`,`aux_th`.`station` AS `station`,`aux_th`.`sensor` AS `sensor`,`aux_th`.`temp` AS `temp`,`aux_th`.`humidity` AS `humidity`,`aux_th`.`batt` AS `batt` from `aux_th` order by `aux_th`.`idx` desc limit 100;

-- 2024-08-27 20:53:14

