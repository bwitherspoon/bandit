
vpath %.sv ../syn

bandit_test.vcd: bandit_test.vvp
	vvp -n -l- $< -vcd +dump=$@ >/dev/null 2>$(@:.vcd=.log)

bandit_test.vvp: bandit_test.sv bandit.sv
	iverilog -y ../syn -g2012 -Wall -tvvp -o $@ $^

clean:
	-$(RM) *.vcd *.vvp *.log

.PHONY: clean
