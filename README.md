# XGZP6897D Berry Driver for Tasmota

This is an incredibly low effort (AI slop) Berry driver for the XGZP6897D family of I2C pressure sensors from CFSensor.com, ported from https://github.com/fanfanlatulipe26/XGZP6897D. The driver (hopefully) allows these sensors to be used with Tasmota firmware on ESP32 devices (8266 not supported because Berry isn't supported).

This is part of a project to add *just enough* negative pressure to my 3d printer to save me from all the VOCs/particles it makes without impacting internal temperatures too much, as suggested [here](https://www.reddit.com/r/BambuLab/s/q53txqYEhE). It is similarly *just enough* work to get me some sensor readings.

## Features
- I didn't really have to do any work for this
- Automatically detects sensor on I2C bus
- Reads temperature (°C) and pressure (Pa) values
- Displays readings in Tasmota web UI
- Adds readings to Tasmota's MQTT telemetry
- Non-blocking operation with timeout handling
- Compatible with all sensors in the XGZP6897D family

## Supported Sensors

This driver *should* work with all I2C pressure sensors from CFSensor that share the same protocol, including:

- XGZP6897D  (Primary Target)
- XGZP6899D  (I don't even know if the rest of this list is real :D)
- XGZP6847D
- XGZP6857D
- XGZP6859D
- XGZP6869D
- XGZP6877D
- XGZP6887D
- XGZP6858D

## Installation

1. Upload the `xgzp6897d.be` file to your Tasmota device using the Tasmota File Manager
2. Add the initialization code to your `autoexec.be` file or run it in the Berry console

## Usage

Basic usage example:

```berry
# Load the driver
load("xgzp6897d.be")

# Create sensor instance with appropriate K factor for your sensor
# Example: K=4096 for a sensor with range -1000~1000Pa
xgzp6897d = XGZP6897D(4096)

# Register the driver with Tasmota
tasmota.add_driver(xgzp6897d)
```

## K Factor Selection

The K factor must be selected according to the specific sensor's pressure range. The K value is selected according to the positive pressure value only. For example, for a sensor with range -100~100kPa, the K value would be 64.

Use the following table as a reference:

| Pressure range (kPa) | K value |
|----------------------|---------|
| 500<P≤1000           | 8       |
| 260<P≤500            | 16      |
| 131<P≤260            | 32      |
| 65<P≤131             | 64      |
| 32<P≤65              | 128     |
| 16<P≤32              | 256     |
| 8<P≤16               | 512     |
| 4<P≤8                | 1024    |
| 2≤P≤4                | 2048    |
| 1≤P<2                | 4096    |
| P<1                  | 8192    |


## Manual Reading

You can manually read the sensor anytime with:

```berry
# Force a sensor reading
xgzp6897d.read_raw_sensor()

# Access the values
print("Temperature:", xgzp6897d.temperature, "°C")
print("Pressure:", xgzp6897d.pressure, "Pa")
```

## Web UI Integration

The driver automatically adds the sensor readings to the Tasmota web UI under the "Sensors" section.

## MQTT Telemetry

The readings are included in the Tasmota MQTT telemetry JSON as:

```json
{
  "XGZP6897D": {
    "Temperature": 25.50,
    "Pressure": 101325.00
  }
}
```

## Automatic Updates

The driver reads the sensor automatically every second, keeping the values up to date for both the web UI and telemetry.

## A note on Licencing
The Original Arduino library is licenced under GPL v3, but is also [released into the public domain](https://github.com/fanfanlatulipe26/XGZP6897D/blob/09a1188201a13d478c6fc9ba6f39e2f4cb57dcc5/src/XGZP6897D.h#L7), which means it can be used freely without any restrictions including those restrictions of the GPL v3.
I'm partial to the MIT licence, so I'm releasing this "port" of the library under the MIT licence. I also don't really care about this, so if the original author cares enough to [create an issue](https://github.com/bertlebee/XGZP6897D/issues/new), I'm happy to change it to the GPL v3 licence. Leave the lawyers at home please :)

## Credits
- [Original Arduino library](https://github.com/fanfanlatulipe26/XGZP6897D)
- [Berry driver port based on Tasmota Berry Cookbook examples](https://tasmota.github.io/docs/Berry-Cookbook/#creating-an-i2c-driver)
- [Zed Agentic Editing](https://zed.dev/agentic) This was a test of Zed's new agentic editing feature. Pretty happy with it so far!
- [Claude 3.7 Sonnet](https://claude.ai/) The model that did all the heavy lifting.
