// Copyright 2018 Brett Witherspoon

`ifndef DUMP_INCLUDED
`define DUMP_INCLUDED

task dump_setup(int levels = 1);
  string file;
  if ($value$plusargs("dump=%s", file)) begin
    $dumpfile(file);
    $dumpvars(levels);
  end
endtask : dump_setup

`endif
