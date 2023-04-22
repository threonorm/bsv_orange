import serial
from vcolorpicker import getColor

ser = serial.Serial('/dev/ttyACM0')

def r(d):
    ser.write(b'r')
    ser.write(d.to_bytes(1,'little'))

def g(d):
    ser.write(b'g')
    ser.write(d.to_bytes(1,'little'))

def b(d):
    ser.write(b'b')
    ser.write(d.to_bytes(1,'little'))

def change_color(rv,gv,bv):
    r(rv)
    g(gv)
    b(bv)

def pick_color():
    r,g,b = getColor()
    change_color(int(r),int(g),int(b))

