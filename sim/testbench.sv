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
  logic action_gready = 0;

  enum {
    SUCCESS,
    FAILURE
  } status = SUCCESS;

  action_value agent(.*);

  task test_agent(int trials, int tests);
    bit signed [7:0] rewards [0:255];
    bit [7:0] action;
    int unsigned result;
    int unsigned errors;

    // FIXME Zero is currently an invalid action
    agent.action_value[0] = -128;
    // TODO Optimistic initial action-values to encourage initial exploration
    for (int i = 1; i < $size(agent.action_value[i]); i++)
      agent.action_value[i] = 0;
    // Reward a signle random action
    for (int i = 0; i < $size(rewards); i++) rewards[i] = -32;
    result = randint(256);
    rewards[result] = 64;

    // Train
    $info("running %0d training trials for action %0d", trials, result);
    repeat (trials) begin
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

    // Test
    errors = 0;
    action_gready = 1;
    repeat (tests) begin
      wait (action_valid == 1);
      @(negedge clock) action_ready = 1;
      @(posedge clock) action = action_data;
      if (action != result) begin
        $error("incorrect action %0d", action_data);
        status = FAILURE;
        errors++;
      end
      wait (action_valid == 0);
      @(negedge clock) begin
        action_ready = 0;
        reward_valid = 1;
        reward_data = rewards[action];
      end
      wait (reward_ready == 1);
      @(posedge clock) #1 reward_valid = 0;
    end
    action_gready = 0;
    $info("passed %0d and failed %0d tests for action %0d", tests - errors, errors, result);
  endtask : test_agent

  initial begin
    dump_setup;
    seed_setup;
    sync_reset;
    test_agent(1000, 100);
    $writememh("action_value.mem", agent.action_value);
    if (status == FAILURE)
      $stop;
    else
      $finish;
  end

endmodule // BanditTest
