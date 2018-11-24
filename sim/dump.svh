// Copyright 2018 Brett Witherspoon

`ifndef DUMP_INCLUDED
`define DUMP_INCLUDED

task dump_setup;
  string file;
  if ($value$plusargs("dump=%s", file)) begin
    $dumpfile(file);
    $dumpvars;
  end
endtask : dump_setup

`endif
