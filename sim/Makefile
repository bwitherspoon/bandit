
syn_dir := ../syn

vpath %.sv $(syn_dir)

testbench.vcd: testbench.vvp
	vvp -n -l- $< -vcd +dump=$@ >/dev/null 2>$(@:.vcd=.log)

testbench.vvp: testbench.sv bandit.sv
	iverilog -Y.sv -y$(syn_dir) -g2012 -u -Wall -tvvp -o $@ $<

clean:
	-$(RM) *.vcd *.vvp *.log *.mem

.PHONY: clean
