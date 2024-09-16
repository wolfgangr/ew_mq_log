This is a companion script to [ecowitt2mqtt](https://github.com/bachya/ecowitt2mqtt)

ecowitt2mqtt provides a server, where ecowitt-compatible weather stations can submit their station readings, and generates mqtt messages from those data.  
The scripts in the project here 
- subscribe to those mqtt topics
- log weather- and sensor-data to mariadb-MySQL-database
- extract auxiliary temp and humidity sensor data
- logs those (after filtering) to a separate database table
- and generates separate mqtt messages for each of them, but only after a configurable change of sensor value

The scripts are not designed as "on size to fit all needs" with elaborated configuration.  
Instead we rely on the power of a Turing-capable language and keep the scripts as KISS as possible.
So, individual changes are supposed to be made right in the source code. 
The scripts are designed rather as a template than as for 1:1 reuse. 

DISCLAIMER: no warranty for anything! 
Expect the scripts to do nothing but the worst!

For further information and development log, see here:  
https://github.com/bachya/ecowitt2mqtt/issues/1080  
'Optionally generate separete MQTT messages for additional sensors'

intended data flow:
```
Station and sensors 
   V--- RF transmission (16 ... 64 s)
Gateway / weather station
   V--- custom gateway ecowitt format (set to 10s)
ecowitt2mqtt (incl. dateutc hack)
   V--- mqtt (processed incl dateutc)
sub parse_ecowitt
   +--> sub log_ecowitt --->  SQL raw table of station outdoor every 16 s
   V--- sub parse_aux (extracts available temp/hum aux per sensor data)
sub do_aux (filters only readings per sensor where values have changed)
   +---> sub log_aux ---> SQL aux_th table with changed readings of every sensor
   V
sub pub_aux (filter configurable change bandwith)
   V--- mqtt retain - payload per sensor
lightweight consumers (TBD)
```

In my setup, I patched ecowitt2mqtt so that it forwards the time when data where delivered by the station in no-raw format, too.  
This is the timestamp we use for SQL logging and republished messages as well. 
This way, the timestamps are not subject to any data path latency. 
see https://github.com/bachya/ecowitt2mqtt/issues/1079

