`ifndef CLOCK_INCLUDED
`define CLOCK_INCLUDED

`define clock(freq=100e6, unit=1e-9) \
  localparam CLOCK_PERIOD = 1.0 / (1.0*(freq)) / (1.0*(unit)); \
  logic clock; \
  initial begin : clock_block \
    clock <= 0; \
    forever #(CLOCK_PERIOD / 2) clock = ~clock; \
  end : clock_block

`endif // CLOCK_INCLUDED
