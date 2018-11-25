// Copyright 2018 Brett Witherspoon

`ifndef RANDOM_INCLUDED
`define RANDOM_INCLUDED

function int unsigned randint(int unsigned max = 2**32);
  static int seed = 0;
  return {$random(seed)} % max;
endfunction : randint

task seed_setup;
  if ($test$plusargs("seed") && !$value$plusargs("seed=%d", randint.seed))
    $error("invalid seed");
  else
    $info("using seed %0d", randint.seed);
endtask : seed_setup

`endif // RANDOM_INCLUDED
