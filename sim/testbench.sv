// Copyright 2018 Brett Witherspoon

`default_nettype none

module bandit_test;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "reset.svh"
  `include "dump.svh"

  `clock()
  `reset()

  logic reward_valid = 0;
  logic [7:0] reward_data;
  logic reward_ready;

  logic action_valid;
  logic [7:0] action_data;
  logic action_ready = 0;

  bit [7:0] action;
  bit signed [7:0] rewards [0:255];

  bandit dut(.*);

  task test_cases(int count);
  begin
    @(negedge clock) action_ready = 1;
    repeat (count) begin
      wait (action_valid == 1);
      action = action_data;
      wait (action_valid == 0);
      @(negedge clock) begin
        reward_valid = 1;
        reward_data = rewards[action];
      end
      wait (reward_ready == 1);
      @(posedge clock) #1 reward_valid = 0;
    end
  end
  endtask : test_cases

  initial begin
    // Optimistic initial values to encourage exploration
    for (int i = 0; i < $size(dut.action_value_table[i]); i++) dut.action_value_table[i] = 5;
    // Reward only a few actions
    for (int i = 0; i < $size(rewards); i++) rewards[i] = 0;
    rewards[64] = 3;
    dump_setup;
    sync_reset;
    test_cases(100);
    @(negedge clock) $finish;
  end

endmodule // BanditTest
