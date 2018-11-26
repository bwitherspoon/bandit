#!/usr/bin/python3

import struct
import sys

def main():
    if len(sys.argv) != 2:
        print("error: missing argument", file=sys.stderr)
        return 1

    with open(sys.argv[1]) as file:
        addr = 0
        for line in file:
            line = line.strip()
            if line.startswith('//'):
                continue
            data, = struct.unpack('>h', bytes.fromhex(line))
            print('{}: {}'.format(addr, data))
            addr += 1

if __name__ == '__main__':
    sys.exit(main());
