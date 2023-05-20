import serial
from vcolorpicker import getColor

ser = serial.Serial('/dev/ttyACM0')

READ = 0
READ = READ.to_bytes(4,'little')

WRITE = 1
WRITE = WRITE.to_bytes(4,'little')


def axi_read(addr):
    ser.write(READ)
    ser.write(addr.to_bytes(4,'little'))
    res = ser.read(4)
    return (int.from_bytes(res,'little'))

def axi_write(addr,data):
    ser.write(WRITE)
    ser.write(addr.to_bytes(4,'little'))
    ser.write(data.to_bytes(4,'little'))

# Initialization routine:
# 

