module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  SmartmeterObis = require 'smartmeter-obis'

  class SmartmeterObisPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass('SmartmeterObisDevice', {
        configDef: deviceConfigDef.SmartmeterObisDevice,
        createCallback: (config) => new SmartmeterObisDevice(config, @framework, deviceConfigDef.SmartmeterObisDevice)
      })

  class SmartmeterObisDevice extends env.devices.Device

    actualusage: 0.0
    totalusage: 0.0
    tariff1totalusage: 0.0
    tariff2totalusage: 0.0
    gastotalusage: 0.0
    totaldelivery: 0.0
    tariff1totaldelivery: 0.0
    tariff2totaldelivery: 0.0


    constructor: (config, framework, configDef) ->
      @config = config
      @id = @config.id
      @name = @config.name
      schema = configDef.properties

      @options = {
        protocol: if @config.protocol then @config.protocol else config.protocol,
        transport: "SerialResponseTransport",
        transportSerialPort: if @config.serialPort? then @config.serialPort else config.serialPort,
        transportSerialBaudrate: if @config.baudRate? then @config.baudRate else config.baudRate,
        transportSerialDataBits: if @config.dataBits? then @config.dataBits else config.dataBits,
        transportSerialParity: if @config.parity? then @config.parity else config.parity,
        transportSerialStopBits: if @config.stopBits? then @config.stopBits else config.stopBits,
        requestInterval: if @config.requestInterval? then @config.requestInterval else config.requestInterval,
        obisNameLanguage: 'en',
        debug: if @config.debuglevel? then @config.debuglevel else config.debuglevel
        }

      @smartmeterObis = SmartmeterObis.init(@options, @processData)
      @smartmeterObis.process()

      @attributes = {}
      
      # initialise all attributes
      for attr, i in @config.obisValues
        do (attr) =>
          try
            name = attr.name
            obs = attr.obis
            if name in schema.obisValues.items.properties.name.enum
              #@attributes[name] = {
              #  description: name
              #  type: "number"
              #}
            else
              throw new Error("Illegal attribute name: #{name} in Smartmeter config.")

            switch name
              when "totalusage"
                getter = ( =>
                  Promise.resolve @totalusage
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:1.8.0' else obs
                  acronym: 'T in'
                  unit: 'kWh'
                }
              when "tariff1totalusage"
                getter = ( =>
                  Promise.resolve @tariff1totalusage
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:1.8.1' else obs
                  acronym: 'T1 in'
                  unit: 'kWh'
                }
              when "tariff2totalusage"
                getter = ( =>
                  Promise.resolve @tariff2totalusage
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:1.8.2' else obs
                  acronym: 'T2 in'
                  unit: 'kWh'
                }
              when "actualusage"
                getter = ( =>
                  Promise.resolve @actualusage
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:1.7.0' else obs
                  acronym: 'actual'
                  unit: 'kW'
                }
              when "gastotalusage"
                getter = ( =>
                  Promise.resolve @gastotalusage
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '0-1:24.2.1' else obs
                  acronym: 'Gas'
                  unit: 'm3'
                }
              when "totaldelivery"
                getter = ( =>
                  Promise.resolve @totaldelivery
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:2.8.0' else obs
                  acronym: 'T out'
                  unit: 'kWh'
                }
              when "tariff1totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff1totaldelivery
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:2.8.1' else obs
                  acronym: 'T1 out'
                  unit: 'kWh'
                }
               when "tariff2totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff2totaldelivery
                )
                @attributes[name] = {
                  description: name
                  type: "number"
                  obis: if !(obs?) then '1-0:2.8.2' else obs
                  acronym: 'T2 out'
                  unit: 'kWh'
                }
               else
                throw new Error("Illegal attribute name: #{name} in Smartmeter.")

            # Create a getter for this attribute
            @_createGetter(name, getter)

          catch err
            env.logger.error err.message

      super()

    _reconnect: () =>
      env.logger.info "restart connection with samrtmeter in 5 seconds"
      @smartmeterObis.process()

    processData: (err, obisResult) =>
      if err
        env.logger.error err
        #@smartmeterObis.stop
        #setTimeout(_reconnect, 5000);
        return

      if @options.debug == 2 then env.logger.info obisResult

      for name, i of @attributes
        do (name) =>
          try
            if !(obisResult[i.obis]?)
              env.logger.info "Your smartmeter does't support OBIS value: #{i.obis} = " + name
              return
            switch name
              when "actualusage"
                if obisResult[i.obis]? then _actualUsage = obisResult[i.obis].values[0].value else _actualUsage = 0
                @actualusage = Number _actualUsage
                @emit "actualusage", Number @actualusage
              when "totalusage"
                if obisResult[i.obis]? then _totalUsage = obisResult[i.obis].values[0].value else _totalUsage = 0
                @totalusage = Number _totalUsage
                @emit "totalusage", Number @totalusage
              when "tariff1totalusage"
                if obisResult[i.obis]?.values[0].value? then _tariff1TotalUsage = obisResult[i.obis].values[0].value else _tariff1TotalUsage = 0
                @tariff1totalusage = Number _tariff1TotalUsage.toFixed 0
                @emit "tariff1totalusage", Number @tariff1totalusage
              when "tariff2totalusage"
                if obisResult[i.obis]? then _tariff2TotalUsage = obisResult[i.obis].values[0].value else _tariff2TotalUsage = 0
                @tariff2totalusage = Number _tariff2TotalUsage.toFixed 0
                @emit "tariff2totalusage", Number @tariff2totalusage
              when "gastotalusage"
                if obisResult[i.obis]? then _gasTotalUsage = obisResult[i.obis].values[1].value else _gasTotalUsage = 0
                @gastotalusage = Number _gasTotalUsage
                @emit "gastotalusage", Number @gastotalusage
              when "totaldelivery"
                if obisResult[i.obis]? then _totalDelivery = obisResult[i.obis].values[0].value else _totalDelivery = 0
                @totaldelivery = Number _totalDelivery
                @emit "totaldelivery", Number @totaldelivery
              when "tariff1totaldelivery"
                if obisResult[i.obis]? then _tariff1TotalDelivery = obisResult[i.obis].values[0].value else _tariff1TotalDelivery = 0
                @tariff1totaldelivery = Number _tariff1TotalDelivery.toFixed 0
                @emit "tariff1totaldelivery", Number @tariff1totaldelivery
              when "tariff2totaldelivery"
                if obisResult[i.obis]? then _tariff2TotalDelivery = obisResult[i.obis].values[0].value else _tariff2TotalDelivery = 0
                @tariff2totaldelivery = Number _tariff2TotalDelivery.toFixed 0
                @emit "tariff2totaldelivery", Number @tariff2totaldelivery
          catch err
            env.logger.error err.message
      
    destroy: () ->
      @smartmeterObis.stop()
      super()

  return new SmartmeterObisPlugin
