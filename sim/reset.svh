`ifndef RESET_INCLUDED
`define RESET_INCLUDED

`define reset \
  logic reset = 0; \
  task hold_reset; \
  begin \
    reset = 1; \
    repeat (2) @ (posedge clock); \
    #1 reset = 0; \
  end \
endtask : hold_reset

`endif // RESET_INCLUDED
