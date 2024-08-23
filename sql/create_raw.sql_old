/* derived from
   https://github.com/wolfgangr/weather-server/blob/master/raw.sql
 */

CREATE TABLE IF NOT EXISTS `raw` (
  `idx` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `station` int(2) DEFAULT NULL,
  `hum_out` decimal(3,0) DEFAULT NULL,
  `temp_out` decimal(4,1) DEFAULT NULL,
  `dewpoint` decimal(4,1) DEFAULT NULL,
  `hum_abs`  decimal(5,2) DEFAULT NULL,
  `wind_ave` decimal(5,1) DEFAULT NULL,
  `wind_gust` decimal(5,1) DEFAULT NULL,
  `wind_dir` decimal(3,0) DEFAULT NULL,
  `rain_count` decimal(6,1) DEFAULT NULL,
  `baro_abs` decimal(6,2) DEFAULT NULL,
  `sol_rad` decimal(5,1) DEFAULT NULL,
  `uv_rad` decimal(2,1) DEFAULT NULL,
  `batt` int(2) DEFAULT NULL,
  PRIMARY KEY (`idx`,`station`)
)
