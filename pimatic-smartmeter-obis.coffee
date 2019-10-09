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

      @smartmeterLogged = false
      @obisNotSupprtedMsg = false

      @attributes = {}
      
      # initialise all attributes
      for attr, i in @config.obisValues
        do (attr) =>
          try
            name = attr.name
            obs = attr.obis
            acr = attr.acronym
            uni = attr.unit
            if !name in schema.obisValues.items.properties.name.enum
              throw new Error("Illegal attribute name: #{name} in Smartmeter config.")

            switch name
              when "totalusage"
                getter = ( =>
                  Promise.resolve @totalusage
                )
                @_setAttr(attr, "number", "1-0:1.8.0", "T in", "kWh" )
              when "tariff1totalusage"
                getter = ( =>
                  Promise.resolve @tariff1totalusage
                )
                @_setAttr(attr, "number", "1-0:1.8.1", "T1 in", "kWh" )
              when "tariff2totalusage"
                getter = ( =>
                  Promise.resolve @tariff2totalusage
                )
                @_setAttr(attr, "number", "1-0:1.8.2", "T2 in", "kWh" )
              when "actualusage"
                getter = ( =>
                  Promise.resolve @actualusage
                )
                @_setAttr(attr, "number", "1-0:1.7.0", "actual", "kW" )
              when "gastotalusage"
                getter = ( =>
                  Promise.resolve @gastotalusage
                )
                @_setAttr(attr, "number", "0-1:24.2.1", "Gas", "m3" )
              when "totaldelivery"
                getter = ( =>
                  Promise.resolve @totaldelivery
                )
                @_setAttr(attr, "number", "1-0:2.8.0", "T out", "kWh" )
              when "tariff1totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff1totaldelivery
                )
                @_setAttr(attr, "number", "1-0:2.8.1", "T1 out", "kWh" )
              when "tariff2totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff2totaldelivery
                )
                @_setAttr(attr, "number", "1-0:2.8.2", "T2 out", "kWh" )
              else
                throw new Error("Illegal attribute name: #{name} in Smartmeter.")

            # Create a getter for this attribute
            @_createGetter(name, getter)

          catch err
            env.logger.error err.message

      super()

    _setAttr: (attr, t, obs, acr, uni) =>
      @attributes[attr.name] = {
        description: attr.name
        type: t
        obis: if !(attr.obis?) then obs else attr.obis
        acronym: if !(attr.acronym?) then acr else attr.acronym
        unit: if !(attr.unit?) then uni else attr.unit
      }

    processData: (err, obisResult) =>
      if err
        env.logger.error err
        return

      if @options.debug == 2 then env.logger.debug obisResult
      if @config.capabilityLog && !@smartmeterLogged
        log = "Smartmeter Capabilities (Obis ID: Description = Current Value):" + '\n'
        for obisId of obisResult
          log = log + obisResult[obisId].idToString() + ': ' +
            SmartmeterObis.ObisNames.resolveObisName(obisResult[obisId], @options.obisNameLanguage).obisName + ' = ' +
            obisResult[obisId].valueToString() + '\n'
        @smartmeterLogged = true
        env.logger.info log

      for name, i of @attributes
        do (name) =>
          try
            if !(obisResult[i.obis]?)
              if !@obisNotSupprtedMsg
                env.logger.info "Your smartmeter does't support OBIS value: #{i.obis} = " + name
                @obisNotSupprtedMsg = true
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
                @tariff1totalusage = Number _tariff1TotalUsage
                @emit "tariff1totalusage", Number @tariff1totalusage
              when "tariff2totalusage"
                if obisResult[i.obis]? then _tariff2TotalUsage = obisResult[i.obis].values[0].value else _tariff2TotalUsage = 0
                @tariff2totalusage = Number _tariff2TotalUsage
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
                @tariff1totaldelivery = Number _tariff1TotalDelivery
                @emit "tariff1totaldelivery", Number @tariff1totaldelivery
              when "tariff2totaldelivery"
                if obisResult[i.obis]? then _tariff2TotalDelivery = obisResult[i.obis].values[0].value else _tariff2TotalDelivery = 0
                @tariff2totaldelivery = Number _tariff2TotalDelivery
                @emit "tariff2totaldelivery", Number @tariff2totaldelivery
          catch err
            env.logger.error err.message
      
    destroy: () ->
      @smartmeterObis.stop()
      super()

  return new SmartmeterObisPlugin
