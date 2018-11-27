# Copyright 2018 Brett Witherspoon

icestick.bin: icestick.asc
	icepack $< $@

icestick.asc: icestick.json
	nextpnr-ice40 --json $< --pcf $(@:.asc=.pcf) --asc $@

icestick.json: icestick.v transmit.v receive.v action_value.sv
	yosys -p "synth_ice40 -json $@" $^

clean:
	-$(RM) *.asc *.bin *.json
