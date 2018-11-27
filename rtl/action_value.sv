// Copyright 2018 Brett Witherspoon

`timescale 1ns / 1ps
`default_nettype none

module action_value #(
  parameter INIT = "",
  parameter SEED = 8'hff,
  parameter TAPS = 8'hb1 // x^8 + x^6 + x^5 + x^4 + 1
)(
  input logic clock,
  input logic reset,

  input logic reward_valid,
  input logic [7:0] reward_data,
  output logic reward_ready,

  output logic action_valid,
  output logic [7:0] action_data,
  input logic action_ready,
  input logic action_gready
);
  // State register
  localparam DECIDING = 2'b00;
  localparam ACTUATING = 2'b01;
  localparam OBSERVING = 2'b10;
  logic [1:0] state;

  // Memory for action-value table
  logic [15:0] action_value [0:255];

  if (INIT != "") initial $readmemh(INIT, action_value, 0, 255);

  // Pseudo-random action from action-value table
  logic [7:0] action;

  // Value of pseudo-random acion from action-value table
  logic signed [15:0] value;

  // Delay register to align action with values
  logic [7:0] value_action;

  // Counter for action-value table decision
  logic [7:0] index;

  // Register for action taken
  logic [7:0] actuation;

  // Register for value of action taken
  logic signed [15:0] utility;

  // Counter for actions taken
  logic [3:0] count;

  // Wire for reward of action taken
  wire signed [7:0] reward = reward_data;

  // Wire for action-value update Q_{n+1} = Q_n + \alpha [R_n - Q_n]
  wire signed [15:0] update = utility + ((reward - utility) >>> 3);

  // Wire for exploration signal
  wire explore = ~action_gready & count == 15;

  // Wire for exploitation signal
  wire exploit = index == 255;

  // Mealy finite-state machine
  initial state = DECIDING;
  always_ff @(posedge clock) begin
    if (reset) begin
      state <= DECIDING;
    end else begin
      case (state)
        DECIDING:
          if (explore | exploit) state <= ACTUATING;
        ACTUATING:
          if (action_ready) state <= OBSERVING;
        OBSERVING:
          if (reward_valid) state <= DECIDING;
        default:
`ifdef FORMAL
          assert(state != 2'b11)
`endif
          ;
      endcase
    end
  end

  // Fibonacci LFSR for pseudo-random action
  initial action = SEED;
  always_ff @(posedge clock) begin
    if (reset) begin
      action <= SEED;
    end else begin
      action <= action << 1;
      action[0] <= ^(action & TAPS);
    end
  end

  // Delay register to align action with value
  always_ff @(posedge clock) value_action <= action;

  // Read memory for action-value table
  always_ff @(posedge clock) begin
    value <= action_value[action];
  end

  // Write memory for action-value table
  always_ff @(posedge clock) begin
    if (state == OBSERVING & reward_valid)
      action_value[actuation] <= update;
  end

  // Explore or exploit A_n = argmax Q_n(a)
  initial utility = -128;
  always_ff @(posedge clock) begin
    if (reset) begin
      utility <= -128;
    end else if (state == DECIDING) begin
      if (explore || value > utility) begin
        actuation <= value_action;
        utility <= value;
      end
    end else if (state == OBSERVING & reward_valid) begin
        actuation <= 0;
        utility <= -128;
    end
  end

  // Counter for action-value decision state
  initial index = 0;
  always_ff @(posedge clock) begin
    if (reset)
      index <= 0;
    else if (state == DECIDING)
      index <= index + 1;
  end

  // Counter of actions for approximating epsilon-greedy method
  initial count = 0;
  always_ff @(posedge clock) begin
    if (reset)
      count <= 0;
    else if (action_valid & action_ready)
      count <= count + 1;
  end

  assign reward_ready = state == OBSERVING;
  assign action_valid = state == ACTUATING;
  assign action_data = actuation;

endmodule // bandit
