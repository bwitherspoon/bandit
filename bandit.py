#!/usr/bin/python3

# Copyright 2018 Brett Witherspoon

import serial
import struct

with serial.Serial('/dev/ttyUSB1') as ser:
    ser.write(struct.pack('B', 0))
    action, = struct.unpack('B', ser.read())
    print('{}'.format(action))
