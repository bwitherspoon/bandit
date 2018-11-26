
rtl_dir := ../rtl

vpath %.v $(rtl_dir)

all: testbench.vvp

test: testbench.vvp
	vvp -N -l- $< -vcd +dump=$(<:.vvp=.vcd) +seed=$(shell echo $$RANDOM) >/dev/null 2>$(<:.vvp=.log)

testbench.vvp: testbench.sv action_value.v
	iverilog -Y.sv -y$(rtl_dir) -g2012 -u -Wall -tvvp -o $@ $<

clean:
	-$(RM) *.vcd *.vvp *.log *.mem

.PHONY: all test clean
