module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  SmartmeterObis = require 'smartmeter-obis'

  class SmartmeterObisPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass('SmartmeterObisDevice', {
        configDef: deviceConfigDef.SmartmeterObisDevice,
        createCallback: (config) => new Smartmeter3Device(config, @framework, deviceConfigDef.SmartmeterObisDevice)
      })

  class SmartmeterObisDevice extends env.devices.Device

    actualusage: 0.0
    totalusage: 0.0
    tariff1totalusage: 0.0
    tariff2totalusage: 0.0
    gastotalusage: 0.0
    tariff1totaldelivery: 0.0
    tariff2totaldelivery: 0.0


    constructor: (config, @framework, configDef) ->
      @config = config
      @id = @config.id
      @name = @config.name
      schema = configDef.properties

      @options = {
        protocol: if @config.protocol then @config.protocol else config.protocol,
        transport: "SerialResponseTransport",
        transportSerialPort: if @config.serialPort then @config.serialPort else config.serialPort,
        transportSerialBaudrate: if @config.baudRate then @config.baudRate else config.baudRate,
        requestInterval: if @config.requestInterval then @config.requestInterval else config.requestInterval,
        obisNameLanguage: 'en'
        #debug: 2
        }
      @smartmeterObis = SmartmeterObis.init(@options, @processData)
      @smartmeterObis.process()

      @attributes = {}
      
      # initialise all attributes
      for attr, i in @config.obisValues
        do (attr) =>
          try
            name = attr.name
            if name in schema.obisValues.items.properties.name.enum
              @attributes[name] = {
                description: name
                type: "number"
              }
            else
              throw new Error("Illegal attribute name: #{name} in Smartmeter config.")

            switch name
              when "totalusage"
                getter = ( =>
                  Promise.resolve @totalusage
                )
                @attributes[name].obis = '1-0:1.8.0'
                @attributes[name].acronym = 'T in'
                @attributes[name].unit = 'kWh'

              when "tariff1totalusage"
                getter = ( =>
                  Promise.resolve @tariff1totalusage
                )
                @attributes[name].obis = '1-0:1.8.1'
                @attributes[name].acronym = 'T1 in'
                @attributes[name].unit = 'kWh'
              when "tariff2totalusage"
                getter = ( =>
                  Promise.resolve @tariff2totalusage
                )
                @attributes[name].obis = '1-0:1.8.2'
                @attributes[name].acronym = 'T2 in'
                @attributes[name].unit = 'kWh'
              when "actualusage"
                getter = ( =>
                  Promise.resolve @actualusage
                )
                @attributes[name].obis = '1-0:1.7.0'
                @attributes[name].acronym = 'Actual'
                @attributes[name].unit = 'W'
              when "gastotalusage"
                getter = ( =>
                  Promise.resolve @gastotalusage
                )
                @attributes[name].obis = '0-1:24.2.1'
                @attributes[name].acronym = 'Gas'
                @attributes[name].unit = 'm3'
              when "totaldelivery"
                getter = ( =>
                  Promise.resolve @totaldelivery
                )
                @attributes[name].obis = '1-0:2.8.0'
                @attributes[name].acronym = 'T out'
                @attributes[name].unit = 'kWh'
              when "tariff1totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff1totaldelivery
                )
                @attributes[name].obis = '1-0:2.8.1'
                @attributes[name].acronym = 'T1 out'
                @attributes[name].unit = 'kWh'
              when "tariff2totaldelivery"
                getter = ( =>
                  Promise.resolve @tariff2totaldelivery
                )
                @attributes[name].obis = '1-0:2.8.1'
                @attributes[name].acronym = 'T2 out'
                @attributes[name].unit = 'kWh'
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

      for name, i of @attributes
        #env.logger.info obisResult[i.obis].values[0].value
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
      @smartmeterObis.stop
      @attributes = {}
      super()

  return new SmartmeterObisPlugin
