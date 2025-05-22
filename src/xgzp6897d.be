#- 
 - Berry driver for XGZP6897D pressure sensor family from CFSensor.com
 - Ported from the Arduino library by Francis Sourbier
 - I2C pressure sensor driver
 -#

class XGZP6897D
  var wire        # wire object if device was detected
  var K           # K factor for the specific sensor
  var temperature # last temperature reading in °C
  var pressure    # last pressure reading in Pa
  
  # Constructor - pass the K factor depending on sensor range
  def init(k_factor)
    self.K = k_factor
    self.temperature = 0.0
    self.pressure = 0.0
    
    # Scan for device on I2C bus - default address is 0x6D
    self.wire = tasmota.wire_scan(0x6D, 58)  # 58 is a placeholder I2C index for XGZP6897D
    
    if self.wire
      print("I2C: XGZP6897D detected on bus "+str(self.wire.bus))
    end
  end
  
  # Read raw temperature and pressure values
  def read_raw_sensor()
    if !self.wire return false end  # exit if not initialized
    
    var pressure_adc = 0
    var temperature_adc = 0
    
    # Start combined conversion for pressure and temperature
    self.wire.write(0x6D, 0x30, 0x0A, 1)
    
    # Wait until conversion is complete (Sco bit in CMD_reg, bit 3)
    var end_time = tasmota.millis() + 20  # 20ms should be enough
    var cmd_reg = 0x08  # Initialize with bit 3 set
    
    while (cmd_reg & 0x08) > 0
      if tasmota.millis() > end_time return false end  # timeout
      self.wire.write(0x6D, 0x30, 0, 0)  # Send register address
      var reg_value = self.wire.read(0x6D, 0x30, 1)
      cmd_reg = reg_value
    end
    
    # Read pressure and temperature registers
    self.wire.write(0x6D, 0x06, 0, 0)  # Send register address
    var data = self.wire.read_bytes(0x6D, 0x06, 5)  # Read 5 bytes (3 for pressure, 2 for temp)
    
    # Convert the bytes to raw values
    pressure_adc = (data.get(0, 1) << 16) | (data.get(1, 1) << 8) | data.get(2, 1)
    # Check sign bit and extend to full 32-bit signed value
    if pressure_adc & 0x800000 pressure_adc |= 0xFF000000 end
    
    temperature_adc = (data.get(3, 1) << 8) | data.get(4, 1)
    
    # Convert raw values to actual measurements
    self.pressure = pressure_adc / self.K
    self.temperature = temperature_adc / 256.0
    
    return true
  end
  
  # Read sensor and update values
  def every_second()
    self.read_raw_sensor()
  end
  
  # Display sensor values in web UI
  def web_sensor()
    if !self.wire return nil end
    
    import string
    var msg = string.format(
      "{s}XGZP6897D Temperature{m}%.2f °C{e}"..
      "{s}XGZP6897D Pressure{m}%.2f Pa{e}",
      self.temperature, self.pressure
    )
    tasmota.web_send_decimal(msg)
  end
  
  # Add sensor data to telemetry JSON
  def json_append()
    if !self.wire return nil end
    
    import string
    var msg = string.format(",\"XGZP6897D\":{\"Temperature\":%.2f,\"Pressure\":%.2f}",
      self.temperature, self.pressure)
    tasmota.response_append(msg)
  end
end