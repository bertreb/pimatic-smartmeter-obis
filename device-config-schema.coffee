module.exports = {
  title: "pimatic-smartmeter-obis device config schemas"
  SmartmeterObisDevice: {
    title: "Smartmeter config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      protocol:
        description: "Protocol to be used; D0Protocol or SmlProtocol"
        type: "string"
        default: "D0Protocol"
        enum: ["D0Protocol", "SmlProtocol"]
      serialPort:
        description: "Serialport name (e.g. /dev/ttyUSB0)"
        type: "string"
        default: "/dev/ttyUSB0"
      baudRate:
        description: "Baudrate to use for communicating with smartmeter (e.g. 115200)"
        type: "integer"
        default: 115200
      dataBits:
        description: "Number of databits to use (e.g. 7)"
        type: "integer"
        default: 8
      parity:
        description: "Parity to use (can be 'none', 'even', 'mark', 'odd', 'space')"
        type: "string"
        default: "none"
      stopBits:
        description: "Number of stopBits to use (can be 1 or 2)"
        type: "integer"
        default: 1
      debuglevel:
        description: "Debuglevel (can be 0 (none), 1 (basic) or 2 (detailed))"
        type: "integer"
        default: 0    
      requestInterval:
        description: "Interval between measurements (in seconds)"
        type: "integer"
        default: 10
      obisValues:
        description: "attributes that will be exposed in the device"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            name:
              enum: ["totalusage", "tariff1totalusage", "tariff2totalusage", "actualusage", "gastotalusage","totaldelivery","tariff1totaldelivery","tariff2totaldelivery"]
              description: "smartmeter related attributes"
            obis:
              type: "string"
              description: "The OBIS identifier for the specific value. Format a-b:c.d.e"
              required: true
              default: ""
            acronym:
              type: "string"
              description: "The attribute acronym text to be displayed. The name will be displayed if not set"
              required: false
              default: ""
            unit:
              type: "string"
              description: "The attribute unit to be displayed"
              required: false
              default: ""
  }
}
  