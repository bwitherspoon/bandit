
syn_dir := ../syn

vpath %.sv $(syn_dir)

all: testbench.vvp

test: testbench.vvp
	vvp -n -l- $< -vcd +dump=$(<:.vvp=.vcd) +seed=$(shell echo $$RANDOM) >/dev/null 2>$(<:.vvp=.log)

testbench.vvp: testbench.sv bandit.sv
	iverilog -Y.sv -y$(syn_dir) -g2012 -u -Wall -tvvp -o $@ $<

clean:
	-$(RM) *.vcd *.vvp *.log *.mem

.PHONY: all test clean
