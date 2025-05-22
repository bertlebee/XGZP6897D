# Tasmota Commands for XGZP6897D Berry Driver?

This document describes some custom Tasmota commands that **might** enhance the functionality of the XGZP6897D Berry driver. I didn't ask Claude to write this, don't need it, and didn't test it, but since I've paid for the tokens...

## Adding Custom Commands

The following section provides code for adding custom commands to interact with the XGZP6897D sensor. You can add these to your `autoexec.be` file or run them in the Berry console.

## Command: XGZPRead

Forces an immediate reading of the sensor values.

```berry
def cmd_xgzp_read(cmd, idx, payload, payload_json)
  if xgzp6897d && xgzp6897d.read_raw_sensor()
    var result = {
      "Temperature": xgzp6897d.temperature,
      "Pressure": xgzp6897d.pressure
    }
    tasmota.resp_cmnd(result)
  else
    tasmota.resp_cmnd_error()
  end
end

tasmota.add_cmd('XGZPRead', cmd_xgzp_read)
```

Usage in Tasmota console:
```
XGZPRead
```

## Command: XGZPInfo

Returns information about the sensor configuration.

```berry
def cmd_xgzp_info(cmd, idx, payload, payload_json)
  if xgzp6897d && xgzp6897d.wire
    var result = {
      "K_Factor": xgzp6897d.K,
      "I2C_Bus": xgzp6897d.wire.bus,
      "I2C_Address": "0x6D"
    }
    tasmota.resp_cmnd(result)
  else
    tasmota.resp_cmnd_error()
  end
end

tasmota.add_cmd('XGZPInfo', cmd_xgzp_info)
```

Usage in Tasmota console:
```
XGZPInfo
```

## Command: XGZPUnit

Changes the pressure display unit between Pa, hPa, and kPa.

```berry
# Define a global variable for unit
if !global.contains("xgzp_unit")
  global.xgzp_unit = "Pa"
end

def cmd_xgzp_unit(cmd, idx, payload, payload_json)
  import string

  if payload
    payload = string.toupper(payload)
    if payload == "PA" || payload == "HPA" || payload == "KPA"
      global.xgzp_unit = payload
      tasmota.resp_cmnd_done()
    else
      tasmota.resp_cmnd_error()
    end
  else
    var result = {"Unit": global.xgzp_unit}
    tasmota.resp_cmnd(result)
  end
end

tasmota.add_cmd('XGZPUnit', cmd_xgzp_unit)

# Override the web_sensor method to use the selected unit
def xgzp_web_sensor_with_unit()
  if !xgzp6897d.wire return nil end

  import string
  var pressure = xgzp6897d.pressure
  var unit_str = "Pa"

  if global.xgzp_unit == "HPA"
    pressure = pressure / 100
    unit_str = "hPa"
  elif global.xgzp_unit == "KPA"
    pressure = pressure / 1000
    unit_str = "kPa"
  end

  var msg = string.format(
    "{s}XGZP6897D Temperature{m}%.2f °C{e}"..
    "{s}XGZP6897D Pressure{m}%.2f %s{e}",
    xgzp6897d.temperature, pressure, unit_str
  )
  tasmota.web_send_decimal(msg)
end

# Replace the original web_sensor method
xgzp6897d.web_sensor = xgzp_web_sensor_with_unit
```

Usage in Tasmota console:
```
XGZPUnit         # Returns current unit
XGZPUnit PA      # Set unit to Pascal (default)
XGZPUnit HPA     # Set unit to hectoPascal
XGZPUnit KPA     # Set unit to kiloPascal
```

## Command: XGZPOffsets

Sets or displays calibration offsets for temperature and pressure.

```berry
# Define global variables for offsets
if !global.contains("xgzp_temp_offset")
  global.xgzp_temp_offset = 0.0
end
if !global.contains("xgzp_pres_offset")
  global.xgzp_pres_offset = 0.0
end

def cmd_xgzp_offsets(cmd, idx, payload, payload_json)
  if payload_json != nil
    if payload_json.contains("Temperature")
      global.xgzp_temp_offset = float(payload_json["Temperature"])
    end
    if payload_json.contains("Pressure")
      global.xgzp_pres_offset = float(payload_json["Pressure"])
    end
    tasmota.resp_cmnd_done()
  else
    var result = {
      "Temperature": global.xgzp_temp_offset,
      "Pressure": global.xgzp_pres_offset
    }
    tasmota.resp_cmnd(result)
  end
end

tasmota.add_cmd('XGZPOffsets', cmd_xgzp_offsets)

# Apply offsets when reading
var original_read = xgzp6897d.read_raw_sensor
xgzp6897d.read_raw_sensor = def()
  var success = original_read.call(xgzp6897d)
  if success
    xgzp6897d.temperature += global.xgzp_temp_offset
    xgzp6897d.pressure += global.xgzp_pres_offset
  end
  return success
end
```

Usage in Tasmota console:
```
XGZPOffsets                                 # Display current offsets
XGZPOffsets {"Temperature":-1.5}            # Set temperature offset to -1.5°C
XGZPOffsets {"Pressure":100}                # Set pressure offset to 100 Pa
XGZPOffsets {"Temperature":0,"Pressure":0}  # Reset all offsets to zero
```

## Integration with Rules

You can use these commands in Tasmota rules for automation:

```
Rule1 ON Time#Minute|5 DO XGZPRead ENDON
Rule2 ON Pressure>101500 DO Power1 1 ENDON
```

Enable the rules with:
```
Rule1 1
Rule2 1
```
