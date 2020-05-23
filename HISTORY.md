# Release History

* 20190922, V0.0.3
    * First release of pimatic-smartmeter-obis plugin
* 20190922, V0.0.3
    * Updated configuration
* 20190922, V0.0.4
    * Updated deviceId in smartmeter.coffee
* 20190922, V0.0.5
    * Updated Destroy function in smartmeter.coffee
* 20190923, V0.0.6
	* switched default Actual Usage to kW
	* Completed README.md
* 20190923, V0.0.7
	* bug fix in smartmeter-obis.coffee
* 20190923, V0.0.8
	* removed smartmeterid
* 20190923, v0.0.9
	* bugfix SmlProtocol
* 20190923, v0.0.10
	* added communication settings
	* bugfix on OBIS values config setting
* 20190923, v0.0.11
	* added info dump of received record in debuglevel 2
* 20190923, v0.0.12
	* added configurable acronym and unit per value

* 20190924, v0.1.0
	* made the code compacter
	* added smartmeter capabilities log on (re)start of device
* 20190924, v0.1.1
	* added smartmeter capabilities log to file and debug section on (re)start of device
* 20190924, v0.1.2
	* changed smartmeter capabilities log to Pimatic Info and Debug on (re)start of device
* 20190924, v0.1.3
	* updated smartmeter capabilities log to Pimatic Info (re)start of device
* 20190924, v0.1.4
	* updated smartmeter capabilities log to Pimatic Info (re)start of device
* 20190924, v0.1.5
	* updated smartmeter capabilities log to default false
* 20190926, v0.1.6
	* improved readability in logfile of capabilities log
	* text and code cleanup
* 20190926, v0.1.7
	* bugfix
* 20190927, v0.1.8
	* added node v10 compatibility
* 20190927, v0.1.9
	* some text improvement
* 20191014, v0.1.10
	* 'error log' only when debugLevel = 2
	* add threshold for showing communication errors
* 20191031, v0.1.11
	* completed package.json
* 20200522, v0.1.16
	* add actual delivery
* 20200523, v0.1.17
	* changed unit of actual usage and delivery from kW to W
