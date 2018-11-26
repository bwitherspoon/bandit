// Copyright 2018 Brett Witherspoon

`timescale 1ns / 1ps
`default_nettype none

module action_value #(
  parameter SEED = 8'hff,
  parameter TAPS = 8'hb1 // x^8 + x^6 + x^5 + x^4 + 1
)(
  input wire clock,
  input wire reset,

  input wire reward_valid,
  input wire [7:0] reward_data,
  output wire reward_ready,

  output wire action_valid,
  output wire [7:0] action_data,
  input wire action_ready,
  input wire action_gready
);
  // State register
  localparam DECIDING = 2'b00;
  localparam ACTUATING = 2'b01;
  localparam OBSERVING = 2'b10;
  reg [1:0] state = DECIDING;

  // Memory for action-value table
  reg [15:0] action_value [0:255];

  // Pseudorandom action from action-value table
  reg [7:0] action = SEED;

  // Delay register to align action with values
  reg [7:0] value_action;

  // Value of pseudorandom acion from action-value table
  reg signed [15:0] value;

  // Counter for action-value table decision
  reg [7:0] index = 0;

  // Register for action taken
  reg [7:0] actuation;

  // Register for value of action taken
  reg signed [15:0] utility = -128;

  // Counter for actions taken
  reg [3:0] count = 0;

  // Wire for signed reward of action taken
  wire signed [7:0] reward = reward_data;

  // Wire for action-value update Q_{n+1} = Q_n + \alpha [R_n - Q_n]
  wire signed [15:0] update = utility + ((reward - utility) >>> 3);

  // Wire for explore signal
  wire explore = ~action_gready & count == 15;

  // Wire for exploit signal
  wire exploit = index == 255;

  // Mealy finite-state machine
  always @(posedge clock) begin
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
          ;
      endcase
    end
  end

  // Fibonacci LFSR for pseudorandom action
  always @(posedge clock) begin
    if (reset) begin
      action <= SEED;
    end else begin
      action <= action << 1;
      action[0] <= ^(action & TAPS);
    end
  end

  // Delay register to align action with value
  always @(posedge clock) value_action <= action;

  // Read memory for action-value table
  always @(posedge clock) begin
    value <= action_value[action];
  end

  // Write memory for action-value table
  always @(posedge clock) begin
    if (state == OBSERVING & reward_valid)
      action_value[actuation] <= update;
  end

  // Decide A_n = argmax Q_n(a)
  always @(posedge clock) begin
    if (reset) begin
      actuation <= 0;
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

  // Counter for action-value decision
  always @(posedge clock) begin
    if (reset)
      index <= 0;
    else if (state == DECIDING)
      index <= index + 1;
  end

  // Counter for actions
  always @(posedge clock) begin
    if (reset)
      count <= 0;
    else if (action_valid & action_ready)
      count <= count + 1;
  end

  assign reward_ready = state == OBSERVING;
  assign action_valid = state == ACTUATING;
  assign action_data = actuation;

endmodule // bandit
