// Copyright 2018 Brett Witherspoon

`default_nettype none

module bandit_test;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "reset.svh"
  `include "dump.svh"

  `clock()
  `reset

  logic reward_valid = 0;
  logic [15:0] reward_data;
  logic reward_ready;

  logic action_valid;
  logic [7:0] action_data;
  logic action_ready = 0;

  bandit bandit(.*);

  initial begin
    for (int i = 0; i < 256; i++) bandit.action_value_table[i] = 0;
    dump_setup;
    #CLOCK_PERIOD;
    hold_reset;
    @(negedge clock) action_ready = 1;
    repeat (10) begin
      wait (action_valid == 1);
      wait (action_valid == 0);
      @(negedge clock) begin
        reward_valid = 1;
        reward_data = $random;
      end
      wait (reward_ready == 1);
      @(posedge clock) #1 reward_valid = 0;
    end
    @(negedge clock) $finish(0);
  end

endmodule // BanditTest
