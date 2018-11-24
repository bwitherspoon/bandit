`ifndef CLOCK_INCLUDED
`define CLOCK_INCLUDED

`define clock(freq=100e6, unit=1e-9, name=clock) \
  localparam CLOCK_PERIOD = 1.0 / (1.0 * (freq)) / (1.0 * (unit)); \
  logic ``name; \
  initial begin : clock_block \
    ``name <= 0; \
    forever #(CLOCK_PERIOD / 2) ``name = ~``name; \
  end : clock_block

`endif // CLOCK_INCLUDED
