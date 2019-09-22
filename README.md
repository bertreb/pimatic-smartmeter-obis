pimatic-smartmeter-obis
===================

Reading "Smartmeter" energy (electricity and gas) usage through P1 port.
This plugin is a based on the smartmeter versions of saberone and rick00001. 
This plugin supports serialport version 6 (node v4 and v8) and gives the possibility to change the regex formulas for the energy values in the device config. 

Installation
------------
To enable the smartmeter plugin add this to the plugins in the config.json file.

```
...
{
  "plugin": "Smartmeter-obis"
}
...
```

and add the following to the devices

```
{
  "id": "smartmeter-obis-dsmt",
  "class": "SmartmeterObisDsmrDevice",
  "name": "xxxx",
  "serialport": "/dev/ttyUSB0",
  "baudRate" : 115200,
  "requestInterval" : 10
}
```

Then install through the standard pimatic plugin install page.


Configuration
-------------
