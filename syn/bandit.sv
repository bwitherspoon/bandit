// Copyright 2018 Brett Witherspoon

`timescale 1ns / 1ps
`default_nettype none

module bandit (
  input logic clock,
  input logic reset,

  input logic reward_valid,
  input logic [15:0] reward_data,
  output logic reward_ready,

  output logic action_valid,
  output logic [7:0] action_data,
  input logic action_ready
);

  logic signed [15:0] action_value_table [0:255];
  logic [7:0] action_value_index = 0;
  logic signed [16:0] action_value = 0;
  logic [ 7:0] action_index = 0;

  initial reward_ready = 0;

  always_ff @(posedge clock) begin
    if (reset) begin
      reward_ready <= 0;
    end else if (reward_ready & reward_valid) begin
      action_value_table[action_index] <= action_value + (($signed(reward_data) - action_value) >> 3);
      reward_ready <= 0;
    end else if (~reward_ready & action_valid & action_ready) begin
      reward_ready <= 1;
    end
  end

  always_ff @(posedge clock) begin
    if (~reward_ready) begin
      if (action_value_table[action_value_index] > action_value) begin
        action_value <= action_value_table[action_value_index];
        action_index <= action_value_index;
      end
      action_value_index <= action_value_index + 1;
    end
  end

  initial action_valid = 0;

  always_ff @(posedge clock) begin
    if (reset) begin
      action_valid <= 0;
    end else if (action_valid & action_ready) begin
      action_valid <= 0;
    end else if (action_value_index == 255) begin
      action_valid <= 1;
      action_data <= action_index;
    end
  end


endmodule // bandit
