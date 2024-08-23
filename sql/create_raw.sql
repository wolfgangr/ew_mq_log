-- Adminer 4.8.1 MySQL 10.11.6-MariaDB-0+deb12u1 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `raw`;
CREATE TABLE `raw` (
  `idx` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `station` int(2) NOT NULL,
  `hum_out` decimal(3,0) DEFAULT NULL,
  `temp_out` decimal(4,1) DEFAULT NULL,
  `dewpoint` decimal(4,1) DEFAULT NULL,
  `hum_abs` decimal(5,2) DEFAULT NULL,
  `wind_ave` decimal(5,1) DEFAULT NULL,
  `wind_gust` decimal(5,1) DEFAULT NULL,
  `wind_dir` decimal(3,0) DEFAULT NULL,
  `rain_count` decimal(6,1) DEFAULT NULL,
  `baro_abs` decimal(6,2) DEFAULT NULL,
  `sol_rad` decimal(5,1) DEFAULT NULL,
  `uv_rad` decimal(2,1) DEFAULT NULL,
  `batt` int(2) DEFAULT NULL,
  PRIMARY KEY (`idx`,`station`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;


-- 2024-08-23 19:20:07

