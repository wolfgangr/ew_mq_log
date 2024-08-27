-- Adminer 4.8.1 MySQL 10.11.6-MariaDB-0+deb12u1 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP VIEW IF EXISTS `last_raw`;
CREATE TABLE `last_raw` (`idx` datetime, `station` int(2), `hum_out` decimal(3,0), `temp_out` decimal(5,2), `dewpoint` decimal(5,2), `hum_abs` decimal(5,2), `wind_ave` decimal(6,2), `wind_gust` decimal(6,2), `wind_dir` decimal(3,0), `rain_count` decimal(6,1), `baro_abs` decimal(6,2), `sol_rad` decimal(5,1), `uv_rad` decimal(2,1), `batt` varchar(5));


DROP TABLE IF EXISTS `raw`;
CREATE TABLE `raw` (
  `idx` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `station` int(2) NOT NULL,
  `hum_out` decimal(3,0) DEFAULT NULL,
  `temp_out` decimal(5,2) DEFAULT NULL,
  `dewpoint` decimal(5,2) DEFAULT NULL,
  `hum_abs` decimal(5,2) DEFAULT NULL,
  `wind_ave` decimal(6,2) DEFAULT NULL,
  `wind_gust` decimal(6,2) DEFAULT NULL,
  `wind_dir` decimal(3,0) DEFAULT NULL,
  `rain_count` decimal(6,1) DEFAULT NULL,
  `baro_abs` decimal(6,2) DEFAULT NULL,
  `sol_rad` decimal(5,1) DEFAULT NULL,
  `uv_rad` decimal(2,1) DEFAULT NULL,
  `batt` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`idx`,`station`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;


DROP VIEW IF EXISTS `recent_raw`;
CREATE TABLE `recent_raw` (`idx` datetime, `station` int(2), `hum_out` decimal(3,0), `temp_out` decimal(5,2), `dewpoint` decimal(5,2), `hum_abs` decimal(5,2), `wind_ave` decimal(6,2), `wind_gust` decimal(6,2), `wind_dir` decimal(3,0), `rain_count` decimal(6,1), `baro_abs` decimal(6,2), `sol_rad` decimal(5,1), `uv_rad` decimal(2,1), `batt` varchar(5));


DROP TABLE IF EXISTS `last_raw`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `last_raw` AS select `raw`.`idx` AS `idx`,`raw`.`station` AS `station`,`raw`.`hum_out` AS `hum_out`,`raw`.`temp_out` AS `temp_out`,`raw`.`dewpoint` AS `dewpoint`,`raw`.`hum_abs` AS `hum_abs`,`raw`.`wind_ave` AS `wind_ave`,`raw`.`wind_gust` AS `wind_gust`,`raw`.`wind_dir` AS `wind_dir`,`raw`.`rain_count` AS `rain_count`,`raw`.`baro_abs` AS `baro_abs`,`raw`.`sol_rad` AS `sol_rad`,`raw`.`uv_rad` AS `uv_rad`,`raw`.`batt` AS `batt` from `raw` order by `raw`.`idx` desc limit 1;

DROP TABLE IF EXISTS `recent_raw`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `recent_raw` AS select `raw`.`idx` AS `idx`,`raw`.`station` AS `station`,`raw`.`hum_out` AS `hum_out`,`raw`.`temp_out` AS `temp_out`,`raw`.`dewpoint` AS `dewpoint`,`raw`.`hum_abs` AS `hum_abs`,`raw`.`wind_ave` AS `wind_ave`,`raw`.`wind_gust` AS `wind_gust`,`raw`.`wind_dir` AS `wind_dir`,`raw`.`rain_count` AS `rain_count`,`raw`.`baro_abs` AS `baro_abs`,`raw`.`sol_rad` AS `sol_rad`,`raw`.`uv_rad` AS `uv_rad`,`raw`.`batt` AS `batt` from `raw` order by `raw`.`idx` desc limit 50;

-- 2024-08-27 20:51:34

