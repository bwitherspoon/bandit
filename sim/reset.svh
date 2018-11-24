// Copyright 2018 Brett Witherspoon

`ifndef RESET_INCLUDED
`define RESET_INCLUDED

`define reset(clock=clock, name=reset) \
  bit ``name; \
  initial ``name <= 0; \
  task sync_reset; \
  begin \
    @(negedge ``clock) ``name = 1; \
    repeat (2) @ (posedge ``clock); \
    #1 ``name = 0; \
  end \
endtask : sync_reset

`endif // RESET_INCLUDED
