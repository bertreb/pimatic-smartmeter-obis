pimatic-smartmeter-obis
===================

Reading energy values from a smartmeter. This plugin is a based on the smartmeter-obis@1.1.3 library from Apollon77.
This plugin supports OBIS smartmeter readings over D0 and SML protocol and is compatible with node v4 to v10.
The OBIS codes for electricity (usage and delivery) and gas (usage) are preset, but can be configured to meet the specs of your smartmeter.

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

After restart of Pimatic the SmartmeterObis device can be added. Below the settings with the default values.

```
{
  "id": "smartmeter-obis",
  "class": "SmartmeterObisDevice",
  "name": "xxxx",
  "protocol": [D0Protocol | SmlProtocol] (D0Protocol is default)
  "serialPort": "/dev/ttyUSB0",
  "baudRate" : 115200,
  "dataBits": 8,
  "parity": "none",
  "stopBits": 1,
  "requestInterval" : 10,
  "capabilityLog": false,
  "debuglevel": 0 (default 0 is no debugging)
  "obisValues":
    name: "smartmeter related attributes"
      ["totalusage", "tariff1totalusage", "tariff2totalusage", 
      "actualusage",   "gastotalusage","totaldelivery",
      "tariff1totaldelivery","tariff2totaldelivery", "actualdelivery"]
    obis: "The OBIS identifier for the specific value."
    acronym: "The attribute acronym text to be displayed."
    unit: "The attribute unit to be displayed."
}
```

The required smartmeter values can be selected on de device configuration page.

Configuration
-------------

Connect your smartmeter via een serial connection to your computer.
Identify the serialport ID and communications settings of the smartmeter connection, on your computer (/dev/.....).
Debuglevel 1 is for basic debugging and level 2 is for detailed debugging. Setting errorMessageThreshold > 0 will display an error message after the chosen number of errors. Setting errorMessageThreshold to 0, will stop the error messages.
When the capabilityLog is switched on, a smartmeter capability list with all the available OBIS values will be generated once on (re)start of the device.
This capability list is writen into the pimatic log under "info".

Create a new SmartmeterObis device.
You can choose between the D0 of Sml protocol depending on the type of smartmeter you are using.

The initial device doesn't expose any values. You need to add them in the device configuration (obisValues).
The available values are:
- actualusage - the actual power consumption (kW)
- totalusage - the total consumed power; sum of Tariff1 and Tariff2 (kWh)
- tariff1totalusage - the total consumed tariff1 (kWh)
- tariff2totalusage - the total consumend tariff2 power (kWh)
- gastotalusage - the total consumed gas (m3)
- totaldelivery - the total delivered power; sum of tariff1 and tariff2 (kWh)
- tariff1totaldelivery - the total delivered power tariff1 (kWh)
- tariff2totaldelivery - the total delivered power tariff2 (kWh)

The OBIS string are preconfigured, based on my smartmeter:
- actualusage: 1-0:1.7.0
- totalusage: 1-0:1.8.0
- tariff1totalusage: 1-0:1.8.1
- tariff2totalusage: 1-0:1.8.2
- gastotalusage: 0-1:24.2.1
- totaldelivery: 1-0:2.8.0
- tariff1totaldelivery: 1-0:2.8.1
- tariff2totaldelivery: 1-0:2.8.2

You can change the OBIS string to get the right values from your smartmeter.
The acronym and unit per value can be customized.
You can use the capabilityLog info to tune your device.

If you want to format the values in the GUI, use xAttributeOptions.
For example: to get rid of the decimals 'behind the dot' use displayFormat: fixed, decimal:0.

The plugin is in development. Please backup Pimatic before you are using it!
