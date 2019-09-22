pimatic-smartmeter-obis
===================

Reading energy values from a smartmeter. This plugin is a based on the smartmeter-obis library from Apollon77. 
This plugin supports OBIS smartmeter readings over D0 and SLM protocol and is compatible with node v4 and v8.
The OBIS codes for electricity (usage and delivery) and gas (usage) are preset, but can be configured to meet the requirements of your smartmeter.

Installation
------------
To enable the smartmeter plugin add this to the plugins section via the GUI or add it in the config.json file.

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
  "id": "smartmeter-obis",
  "class": "SmartmeterObisDevice",
  "name": "xxxx",
  "serialport": "/dev/ttyUSB0",
  "baudRate" : 115200,
  "requestInterval" : 10
}
```

Then install through the standard pimatic plugin install page.


Configuration
-------------
<to be added>
