# Copyright 2018 Brett Witherspoon

icestick.bin: icestick.asc
	icepack $< $@

icestick.asc: icestick.json
	nextpnr-ice40 --quiet --json $< --pcf $(@:.asc=.pcf) --asc $@

icestick.json: icestick.v transmit.v receive.v action_value.sv
	yosys -q -l $(@:.json=.log) -p "synth_ice40 -json $@" $^

clean:
	-$(RM) *.asc *.bin *.json *.log
