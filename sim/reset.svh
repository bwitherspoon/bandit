// Copyright 2018 Brett Witherspoon

`ifndef RESET_INCLUDED
`define RESET_INCLUDED

`define reset(clock=clock, name=reset) \
  logic ``name; \
  initial ``name <= 0; \
  task hold_reset; \
  begin \
    ``name = 1; \
    repeat (2) @ (posedge ``clock); \
    #1 ``name = 0; \
  end \
endtask : hold_reset

`endif // RESET_INCLUDED
