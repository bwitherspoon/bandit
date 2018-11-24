// Copyright 2018 Brett Witherspoon

`timescale 1ns / 1ps
`default_nettype none

module bandit (
  input logic clock,
  input logic reset,

  input logic reward_valid,
  input logic [7:0] reward_data,
  output logic reward_ready,

  output logic action_valid,
  output logic [7:0] action_data,
  input logic action_ready
);

  logic signed [15:0] action_value_table [0:255];
  logic [7:0] action_value_index = 0;
  logic signed [15:0] action_value = 0;
  logic [7:0] action_index = 0;

  // TODO Use enumuration when supported by yosys
  localparam DECIDING = 2'b00;
  localparam ACTUATING = 2'b01;
  localparam OBSERVING = 2'b10;
  logic [1:0] state = DECIDING;

  // Mealy finite-state machine
  always_ff @(posedge clock) begin
    if (reset) begin
      state <= DECIDING;
    end else begin
      case (state)
        DECIDING:
          if (&action_value_index) state <= ACTUATING;
        ACTUATING:
          if (action_valid & action_ready) state <= OBSERVING;
        OBSERVING:
          if (reward_valid & reward_ready) state <= DECIDING;
        default:
          ;
      endcase
    end
  end

  // A_n = argmax Q_n(a)
  always_ff @(posedge clock) begin
    if (reset) begin
      action_value_index <= 0;
    end else if (state == DECIDING) begin
      if (action_value_table[action_value_index] > action_value) begin
        action_value <= action_value_table[action_value_index];
        action_index <= action_value_index;
      end
      action_value_index <= action_value_index + 1;
    end
  end

  // Q_{n+1} = Q_n + \alpha [R_n - Q_n]
  always_ff @(posedge clock) begin
    if (reward_ready & reward_valid) begin
      action_value_table[action_index] <= action_value + (($signed(reward_data) - action_value) >>> 3);
    end
  end

  assign reward_ready = state == OBSERVING;
  assign action_valid = state == ACTUATING;
  assign action_data = action_index;

endmodule // bandit
