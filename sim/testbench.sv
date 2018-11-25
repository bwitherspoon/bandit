// Copyright 2018 Brett Witherspoon

`default_nettype none

module testbench;
  timeunit 1ns;
  timeprecision 1ps;

  `include "clock.svh"
  `include "reset.svh"
  `include "dump.svh"
  `include "random.svh"

  `clock()
  `reset()

  logic reward_valid = 0;
  logic [7:0] reward_data;
  logic reward_ready;

  logic action_valid;
  logic [7:0] action_data;
  logic action_ready = 0;

  bit signed [7:0] rewards [0:255];

  bandit dut(.*);

  task test_cases(int count);
    bit [7:0] action;
    begin
      repeat (count) begin
        wait (action_valid == 1);
        repeat (randint(16)) @(posedge clock);
        @(negedge clock) action_ready = 1;
        @(posedge clock) action = action_data;
        wait (action_valid == 0);
        @(negedge clock) action_ready = 0;
        repeat (randint(16)) @(posedge clock);
        @(negedge clock) begin
          reward_valid = 1;
          reward_data = rewards[action];
        end
        wait (reward_ready == 1);
        @(posedge clock) #1 reward_valid = 0;
      end
    end
  endtask : test_cases

  int unsigned action;

  initial begin
    dump_setup;
    seed_setup;
    // Zero is currently an invalid action
    dut.action_value_table[0] = -128;
    // Optimistic initial action-values to encourage initial exploration
    for (int i = 1; i < $size(dut.action_value_table[i]); i++) dut.action_value_table[i] = 127;
    // Reward only a single random action
    for (int i = 0; i < $size(rewards); i++) rewards[i] = -32;
    action = randint(256);
    $info("preferring action %0d", action);
    rewards[action] = 64;
    sync_reset;
    test_cases(16000);
    $writememb("testbench.mem", dut.action_value_table);
    @(negedge clock) $finish;
  end

endmodule // BanditTest
