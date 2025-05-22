#-
 - Example usage of XGZP6897D Berry driver for Tasmota
 - For CFSensor.com XGZP6897D pressure sensor family
 -#

load("xgzp6897d.be") # Load the driver file

#- 
 - K value for XGZP6897D depends on the pressure range of the sensor.
 - Table from datasheet:
 - 
 - Pressure range (kPa)  | K value
 - ---------------------|--------
 - 500<P≤1000           | 8
 - 260<P≤500            | 16
 - 131<P≤260            | 32
 - 65<P≤131             | 64
 - 32<P≤65              | 128
 - 16<P≤32              | 256
 - 8<P≤16               | 512
 - 4<P≤8                | 1024
 - 2≤P≤4                | 2048
 - 1≤P<2                | 4096
 - P<1                  | 8192
 -
 - The K value is selected according to the positive pressure value only.
 - For example, for a -100~100kPa sensor, the K value would be 64.
 -#

# Create sensor instance with K value 4096 for a sensor with range -1000~1000Pa
xgzp6897d = XGZP6897D(4096)

# Register the driver with Tasmota
tasmota.add_driver(xgzp6897d)

# You can manually read sensor values anytime with:
# xgzp6897d.read_raw_sensor()
# print("Temperature:", xgzp6897d.temperature, "°C")
# print("Pressure:", xgzp6897d.pressure, "Pa")

# The driver automatically updates readings every second 
# and displays them in the Tasmota web UI and telemetry JSON